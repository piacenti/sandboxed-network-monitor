#!/bin/bash
echo "Configuration:"
echo "PROXY_SERVER=$PROXY_SERVER"
echo "PROXY_PORT=$PROXY_PORT"
echo "Setting config variables"
sed -i "s/vPROXY-SERVER/$PROXY_SERVER/g" /etc/redsocks.conf
sed -i "s/vPROXY-PORT/$PROXY_PORT/g" /etc/redsocks.conf
echo "Restarting redsocks and redirecting traffic via iptables"
/etc/init.d/redsocks restart


iptables-legacy -t nat -A OUTPUT ! -d 127.0.0.1 -p tcp --dport 80:8051 -j REDIRECT --to-port 65001
iptables-legacy -t nat -A OUTPUT ! -d 127.0.0.1 -p tcp --dport 8053:65000 -j REDIRECT --to-port 65001


echo "Setting up java to accept certificates"
echo -e "yes" | keytool -import -alias mitmproxy -file mitmproxy/mitmproxy-ca-cert.pem -keystore jdk-11.0.3+7-jre/lib/security/cacerts -storepass changeit 
echo -e "yes" | keytool -import -alias mitmproxy -file mitmproxy/mitmproxy-ca-cert.pem -keystore jdk8u232-b09-jre/lib/security/cacerts -storepass changeit 

# make sure proxy is up before testing the connection
./wait-for-it.sh proxy:8081 -- echo "proxy is up"
# Run app
echo "Testing http access using: http://example.com"
curl http://example.com
while true; do sleep 1000; done