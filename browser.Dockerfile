FROM jess/firefox
WORKDIR /app
ADD redsocks.conf /app
ADD browser_config.sh /app
ADD wait-for-it.sh /app
RUN apt-get update
RUN apt-get upgrade -qy
RUN apt-get install iptables redsocks libnss3-tools curl -qy
COPY redsocks.conf /etc/redsocks.conf
ENTRYPOINT /bin/bash browser_config.sh
