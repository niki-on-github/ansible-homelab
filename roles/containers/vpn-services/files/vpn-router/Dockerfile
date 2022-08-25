FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    openvpn \
    kmod \
    iptables \
    iptables-persistent \
    net-tools \
    ipcalc \
    curl \
    jq \
    iputils-ping \
    inetutils-traceroute \
    python3 \
    python3-pip

RUN pip3 install flask flask_wtf flask_bootstrap wtforms

ADD webui /webui

ADD start.sh /start.sh
RUN chmod +x /start.sh

RUN mkdir /config
VOLUME ["/config"]

ENTRYPOINT ["/start.sh"]
