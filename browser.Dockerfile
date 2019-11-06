FROM jess/firefox@sha256:4b059c0cafa00c53a0e97249f5de0a338a957b406847150052ce7dd25acd2587
WORKDIR /app
ADD redsocks.conf /app
ADD wait-for-it.sh /app
RUN apt-get update
RUN apt-get upgrade -qy
RUN apt-get install iptables redsocks libnss3-tools curl -qy
COPY redsocks.conf /etc/redsocks.conf
ENTRYPOINT /bin/bash scripts/browser_config.sh
