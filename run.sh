#!/bin/bash
echo "Configuration:"
echo "PROXY_SERVER=$PROXY_SERVER"
echo "PROXY_PORT=$PROXY_PORT"
echo "Setting config variables"
sed -i "s/vPROXY-SERVER/$PROXY_SERVER/g" /etc/redsocks.conf
sed -i "s/vPROXY-PORT/$PROXY_PORT/g" /etc/redsocks.conf
echo "Restarting redsocks and redirecting traffic via iptables"
/etc/init.d/redsocks restart
iptables -t nat -A OUTPUT  -p tcp --dport 80 -j REDIRECT --to-port 12345 
iptables -t nat -A OUTPUT  -p tcp --dport 80 -j LOG --log-prefix='[redirect] '
iptables -t nat -A OUTPUT  -p tcp --dport 443 -j REDIRECT --to-port 12345 
iptables -t nat -A OUTPUT  -p tcp --dport 443 -j LOG --log-prefix='[redirect] '

iptables-legacy -t nat -A OUTPUT  -p tcp --dport 80 -j REDIRECT --to-port 12345 
iptables-legacy -t nat -A OUTPUT  -p tcp --dport 80 -j LOG --log-prefix='[redirect] '
iptables-legacy -t nat -A OUTPUT  -p tcp --dport 443 -j REDIRECT --to-port 12345 
iptables-legacy -t nat -A OUTPUT  -p tcp --dport 443 -j LOG --log-prefix='[redirect] '


echo "Setting up java to accept certificates"
echo -e "yes" | keytool -import -alias mitmproxy -file mitmproxy/mitmproxy-ca-cert.pem -keystore jdk-11.0.3+7-jre/lib/security/cacerts -storepass changeit 

# make sure proxy is up before testing the connection
./wait-for-it.sh proxy:8081 -- echo "proxy is up"
# Run app
echo "Testing http access using: http://example.com"
curl http://example.com
while true; do sleep 1000; done