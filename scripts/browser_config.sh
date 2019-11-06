#!/bin/bash
echo "Configuration:"
echo "PROXY_SERVER=$PROXY_SERVER"
echo "PROXY_PORT=$PROXY_PORT"
echo "Setting config variables"
sed -i "s/vPROXY-SERVER/$PROXY_SERVER/g" /etc/redsocks.conf
sed -i "s/vPROXY-PORT/$PROXY_PORT/g" /etc/redsocks.conf
echo "Restarting redsocks and redirecting traffic via iptables"
/etc/init.d/redsocks restart

# Setup firewall rules, redirect all traffic to proxy except for ip used for x11 display 
x11_host=$(echo "$DISPLAY" | sed  "s/:0//g")
x11_ip=$(getent hosts $x11_host | awk '{ print $1 }')
echo $x11_host
echo $x11_ip
#if blank then we're running on linux and there is no need for ip exclusion
if [ "$x11_ip" = "" ]
then
iptables-legacy -t nat -A OUTPUT  -p tcp --dport 80:8051 -j REDIRECT --to-port 65001 
iptables-legacy -t nat -A OUTPUT  -p tcp --dport 8053:65000 -j REDIRECT --to-port 65001 
else
iptables-legacy -t nat -A OUTPUT ! -d $x11_ip  -p tcp --dport 80:8051 -j REDIRECT --to-port 65001 
iptables-legacy -t nat -A OUTPUT ! -d $x11_ip -p tcp --dport 8053:65000 -j REDIRECT --to-port 65001 
fi



# make sure proxy is up before testing the connection
./wait-for-it.sh proxy:8081 -- echo "proxy is up"
# Run app
echo "Testing http access using: http://example.com"
curl http://example.com

startfirefox &>/dev/null &
# wait for firefox to start and create cert9.db so that we can trust certificates
while [ "$(find / -name cert9.db)" = "" ]
do
	sleep 1
done
echo "Setting up firefox to accept certificates"
certificateFile="/app/mitmproxy/mitmproxy-ca-cert.pem"
certificateName="mitmproxy" 
for certDB in $(find  / -name "cert9.db")
do
  certDir=$(dirname ${certDB});
  echo "adding cert to $certDir"
  #log "mozilla certificate" "install '${certificateName}' in ${certDir}"
  certutil -A -n "${certificateName}" -t "TCu,Cuw,Tuw" -i ${certificateFile} -d ${certDir}
done
while true; do sleep 1000; done