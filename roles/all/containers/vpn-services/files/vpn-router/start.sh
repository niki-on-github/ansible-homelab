#!/bin/bash

NAMESERVER=${NAMESERVER:-1.1.1.1}
LAN_NETWORK=${LAN_NETWORK:-192.168.1.0/24}
VPN_CONFIG_PATH="/config"

if [ ! -f /config.sh ]; then
    cat > /config.sh <<EOF
RECONNECT_ENABLED=true
UPDATE_INTERVAL_SEC=8
LOWER_THRESHOLD=60000
UPPER_THRESHOLD=392500
RECONNECT_THRESHOLD_SEC=240
EXCLUDE_START_H=17
EXCLUDE_END_H=21
EOF
fi

vpn_enabled=true
received_bytes=0
old_received_bytes=0
received_velocity=0
old_received_velocity=0
count_low_speed=0
count_no_speed=0
last_epoch=$(date +%s)
config_pos=$((0))

get_openvpn_configs() {
    mapfile -t config_array < <(find "$VPN_CONFIG_PATH" \( -iname "*.ovpn" -o -iname "*.conf" \) -printf "%f\n")

    [ ${#config_array[@]} -le 0 ] \
        && echo "$(date +'%a %b %d %T %Y') [ERROR] OpenVPN config missing" && exit 1
}

get_network_config() {
    docker_interface=$(ip -4 route ls | grep default | xargs | grep -o -P '[^\s]+$')
    docker_ip=$(ifconfig "${docker_interface}" | grep -P -o -m 1 '(?<=inet\s)[^\s]+')
    docker_mask=$(ifconfig "${docker_interface}" | grep -P -o -m 1 '(?<=netmask\s)[^\s]+')
    docker_network_cidr=$(ipcalc "${docker_ip}" "${docker_mask}" | grep -P -o -m 1 "(?<=Network:)\s+[^\s]+" | sed 's/ //g')
    default_gateway=$(ip route show default | awk '/default/ {print $3}')
    echo "[INFO] Docker interface: ${docker_interface}, Docker network: ${docker_network_cidr}, Default gateway: ${default_gateway}"
}

create_tun_device() {
    mkdir -p /dev/net
    [[ -c /dev/net/tun ]] || mknod "/dev/net/tun" c 10 200
    chmod 600 /dev/net/tun
}

iptables_preconfig() {
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP
    iptables -P INPUT DROP
    ip6tables -P OUTPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -P INPUT DROP
    echo "[INFO] Set ip policy DROP"
}

set_default_iptables_policy() {
    # set default input policy
    iptables -P INPUT DROP
    ip6tables -P INPUT DROP

    # accept input from tunnel adapter
    iptables -A INPUT -i tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

    # accept input to local loopback
    iptables -A INPUT -i lo -j ACCEPT

    # set default forward policy
    iptables -P FORWARD DROP
    ip6tables -P FORWARD DROP

    # set default output policy
    iptables -P OUTPUT DROP
    ip6tables -P OUTPUT DROP

    # accept output to tunnel adapter
    iptables -A OUTPUT -o tun+ -j ACCEPT

    # accept output from local loopback adapter
    iptables -A OUTPUT -o lo -j ACCEPT
}

open_webui_ports() {
	echo "[INFO] Adding ${LAN_NETWORK} as route via docker ${docker_interface}"
	ip route add "${LAN_NETWORK}" via "${default_gateway}" dev "${docker_interface}"

    # NOTE: use internal ports of service/webui not the mapped ports
    IFS=',' read -ra web_ui_port_list <<< "${WEBUI_PORTS}"
    for port in "${web_ui_port_list[@]}"; do
        proto=$(echo "$port" | cut -d '/' -f2)
        port=$(echo "$port" | cut -d '/' -f1)
        iptables -A INPUT -i ${docker_interface} -s $LAN_NETWORK -p $proto --dport $port -j ACCEPT
        iptables -A INPUT -s "${docker_network_cidr}" -d "${docker_network_cidr}" -p $proto --dport $port -j ACCEPT
        iptables -A OUTPUT -o ${docker_interface} -d $LAN_NETWORK -p $proto --sport $port -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -s "${docker_network_cidr}" -d "${docker_network_cidr}" -p $proto --sport $port -j ACCEPT
    done
}

set_nameserver() {
    # override existing ns, docker injects ns from host and isp ns can block/hijack
    echo "nameserver $NAMESERVER" > /etc/resolv.conf
}

clean_openvpn_config() {
    [ -f /etc/openvpn/default.conf ] || return

    # allow reconnection to tunnel on disconnect
    sed -i '/^persist-tun/d' /etc/openvpn/default.conf

    # prevent re-checks and dropouts
    sed -i '/^reneg-sec.*/d' /etc/openvpn/default.conf

    # remove up/down scripts
    sed -i '/^up\s.*/d' /etc/openvpn/default.conf
    sed -i '/^down\s.*/d' /etc/openvpn/default.conf

    # remove ipv6 configuration
    sed -i '/^route-ipv6/d' /etc/openvpn/default.conf
    sed -i '/^ifconfig-ipv6/d' /etc/openvpn/default.conf
    sed -i '/^tun-ipv6/d' /etc/openvpn/default.conf

    # remove dhcp option for dns ipv6 configuration
    sed -i '/^dhcp-option DNS6.*/d' /etc/openvpn/default.conf

    # remove windows specific openvpn options
    sed -i '/^route-method exe/d' /etc/openvpn/default.conf
    sed -i '/^service\s.*/d' /etc/openvpn/default.conf
    sed -i '/^block-outside-dns/d' /etc/openvpn/default.conf
}

get_bytes() {
   eval $(cat /proc/net/dev | grep $docker_interface | cut -d ':' -f 2 | awk '{print "received_bytes="$1}')
}

update_velocity() {
   let vel=$received_bytes-$old_received_bytes
   old_received_velocity=$received_velocity
   received_velocity=$vel
   old_received_bytes=$received_bytes
}

reconnect_vpn() {
    [ "$(date +%H)" -ge "$EXCLUDE_START_H" ] && [ "$(date +%H)" -le "$EXCLUDE_END_H" ] && return
    [ "$EXCLUDE_END_H" -lt "$EXCLUDE_START_H" ] && [ "$(date +%H)" -le "$EXCLUDE_END_H" ] && return
    [ "$EXCLUDE_END_H" -lt "$EXCLUDE_START_H" ] && [ "$(date +%H)" -ge "$EXCLUDE_START_H" ] && return
    [ "$config_pos" = "0" ] && [ $(date +%s) -le $(($last_epoch+60*60)) ] \
        && echo "$(date +'%a %b %d %T %Y') [INFO] Prevent reconnect spamming (sleep 3600)" && sleep 3600
    [ "$config_pos" = "0" ] && last_epoch=$(date +%s)
    echo "$(date +'%a %b %d %T %Y') [INFO] Low speed reconnect ..."
    pkill openvpn
}

watch_traffic() {
    while true ; do
        get_bytes
        update_velocity

        [ "$received_velocity" -le "$(($UPDATE_INTERVAL_SEC*$UPPER_THRESHOLD))" ] \
            && [ "$old_received_velocity" -le "$(($UPDATE_INTERVAL_SEC*$UPPER_THRESHOLD))" ] \
            && count_low_speed=$(($count_low_speed+1))

        [ "$received_velocity" -gt "$(($UPDATE_INTERVAL_SEC*$UPPER_THRESHOLD))" ] \
            && [ "$old_received_velocity" -gt "$(($UPDATE_INTERVAL_SEC*$UPPER_THRESHOLD))" ] \
            && count_low_speed=$((0))

        [ "$received_velocity" -le "$(($UPDATE_INTERVAL_SEC*$LOWER_THRESHOLD))" ] \
            && [ "$old_received_velocity" -le "$(($UPDATE_INTERVAL_SEC*$LOWER_THRESHOLD))" ] \
            && count_no_speed=$(($count_no_speed+1))

        [ "$received_velocity" -gt "$(($UPDATE_INTERVAL_SEC*$LOWER_THRESHOLD))" ] \
            && [ "$old_received_velocity" -gt "$(($UPDATE_INTERVAL_SEC*$LOWER_THRESHOLD))" ] \
            && count_no_speed=$((0))

        [ "$count_no_speed" -gt "3" ] && count_low_speed=0
        [ "$count_no_speed" -gt "3600" ] && count_no_speed=3600

        if [ "$count_low_speed" -gt "$(($RECONNECT_THRESHOLD_SEC/$UPDATE_INTERVAL_SEC+1))" ]; then
            [ $RECONNECT_ENABLED = true ] && reconnect_vpn
            count_low_speed=$((0))
        fi

        chmod +x /config.sh && source /config.sh
        sleep $UPDATE_INTERVAL_SEC
    done
}

save_iptables() {
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
}

iptables_preconfig # run as son as possible to prevent ip leaks
chmod +x /config.sh && source /config.sh
get_openvpn_configs
get_network_config
create_tun_device
set_default_iptables_policy
open_webui_ports
save_iptables
set_nameserver
get_bytes
update_velocity
watch_traffic &

close_hook() {
    echo "[INFO] Exit"
    vpn_enabled=false
    pkill openvpn
    pkill flask >dev/null 2>&1
    exit 0
}
trap "close_hook" SIGTERM SIGINT TERM


[ -f /webui/app.py ] && FLASK_APP=/webui/app.py flask run --host=0.0.0.0 &

mkdir -p /etc/openvpn
while [ $vpn_enabled = true ] ; do
    cp -fv $VPN_CONFIG_PATH/${config_array[$config_pos]} /etc/openvpn/default.conf
    clean_openvpn_config

    vpn_server_ip=$(grep "remote " /etc/openvpn/default.conf | cut -d' ' -f2)
    vpn_server_port=$(grep "remote " /etc/openvpn/default.conf | cut -d' ' -f3)
    vpn_server_proto=$(grep "proto " /etc/openvpn/default.conf | cut -d' ' -f2)

    # allow vpn tunnel
    echo "iptables -A OUTPUT -o ${docker_interface} -d $vpn_server_ip -p $vpn_server_proto --dport $vpn_server_port -j ACCEPT"
    iptables -C OUTPUT -o ${docker_interface} -d $vpn_server_ip -p $vpn_server_proto --dport $vpn_server_port -j ACCEPT 2>/dev/null \
    || iptables -A OUTPUT -o ${docker_interface} -d $vpn_server_ip -p $vpn_server_proto --dport $vpn_server_port -j ACCEPT
    echo "iptables -A INPUT -i ${docker_interface} -s $vpn_server_ip -p $vpn_server_proto --sport $vpn_server_port -m state --state RELATED,ESTABLISHED -j ACCEPT"
    iptables -C INPUT -i ${docker_interface} -s $vpn_server_ip -p $vpn_server_proto --sport $vpn_server_port -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
    || iptables -A INPUT -i ${docker_interface} -s $vpn_server_ip -p $vpn_server_proto --sport $vpn_server_port -m state --state RELATED,ESTABLISHED -j ACCEPT

    echo "$(date +'%a %b %d %T %Y') [INFO] Restarting OpenVPN"
    openvpn --inactive 3500 5000000 --config /etc/openvpn/default.conf  >/dev/null &
    PID=$!; wait $PID; wait $PID
    for d in $(netstat -i | cut -d ' ' -f1 | grep '^tun') ; do
        ip addr flush dev $d
    done

    sleep 3

    # remove vpn tunnel
    iptables -D OUTPUT -o ${docker_interface} -d $vpn_server_ip -p $vpn_server_proto --dport $vpn_server_port -j ACCEPT
    iptables -D INPUT -i ${docker_interface} -s $vpn_server_ip -p $vpn_server_proto --sport $vpn_server_port -m state --state RELATED,ESTABLISHED -j ACCEPT

    if [ $(($config_pos+1)) -lt ${#config_array[@]} ]; then
        config_pos=$(($config_pos+1))
    else
        config_pos=$((0))
    fi
done
sleep 3 # finish close_hook
