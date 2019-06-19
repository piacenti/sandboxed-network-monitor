FROM debian:latest
LABEL maintainer="Bruno Amaro Almeida | brunoamaro.com"
# Set the working directory to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
ENV PROXY_SERVER=localhost
ENV PROXY_PORT=8080
RUN apt-get update
RUN apt-get upgrade -qy
RUN apt-get install iptables redsocks curl lynx -qy
RUN curl -o java.tar.gz -L https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7/OpenJDK11U-jre_x64_linux_hotspot_11.0.3_7.tar.gz
RUN tar -xzf java.tar.gz
ENV PATH="${PATH}:/app/jdk-11.0.3+7-jre/bin"
COPY redsocks.conf /etc/redsocks.conf
ENTRYPOINT /bin/bash run.sh