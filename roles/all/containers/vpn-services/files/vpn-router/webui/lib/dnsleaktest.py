import os
import subprocess
import json

from random import randint
from platform import system as system_name
from subprocess import call as system_call

from urllib.request import urlopen

def ping(host):
    fn = open(os.devnull, 'w')
    retcode = system_call(['ping', '-n', '1', host], stdout=fn, stderr=subprocess.STDOUT)
    fn.close()
    return retcode == 0

def run_dnsleaktest(linebreak='<br>'):
    result = '<h1>DNS Leak Test Result</h1>'
    leak_id = randint(1000000, 9999999)
    for x in range(0, 10): ping('.'.join([str(x), str(leak_id), "bash.ws"]))

    response = urlopen("https://bash.ws/dnsleak/test/"+str(leak_id)+"?json")
    data = response.read().decode("utf-8")
    parsed_data = json.loads(data)

    result += str('<h2>IP</h2>')
    for dns_server in parsed_data:
        if dns_server['type'] == "ip":
            if dns_server['country_name']:
                if dns_server['asn']:
                    result += str(dns_server['ip']+" ["+dns_server['country_name']+", " + dns_server['asn']+"]"+linebreak)
                else:
                    result += str(dns_server['ip']+" ["+dns_server['country_name']+"]"+linebreak)
            else:
                result += str(dns_server['ip']+linebreak)

    servers = len([1 for x in parsed_data if x['type'] == 'dns'])
    if servers == 0:
        result += str("<h2>DNS servers found</h2>")
        result += str("- No DNS servers found"+linebreak)
    else:
        result += str("<h2>DNS servers</h2>")
        for dns_server in parsed_data:
            if dns_server['type'] == "dns":
                if dns_server['country_name']:
                    if dns_server['asn']:
                        result += str('- '+dns_server['ip']+" ["+dns_server['country_name'] + ", " + dns_server['asn']+"]"+linebreak)
                    else:
                        result += str('-'+dns_server['ip']+" ["+dns_server['country_name']+"]"+linebreak)
                else: result += str('- '+dns_server['ip']+'\n')

    # result += str("<h2>Conclusion</h2>")
    # for dns_server in parsed_data:
    #     if dns_server['type'] == "conclusion":
    #         if dns_server['ip']: result += str(dns_server['ip'])

    return result

