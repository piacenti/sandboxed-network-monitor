FROM debian@sha256:41f76363fd83982e14f7644486e1fb04812b3894aa4e396137c3435eaf05de88
# Set the working directory to /app
WORKDIR /app
ADD redsocks.conf /app
ADD client_config.sh /app
ADD wait-for-it.sh /app
RUN apt-get update
RUN apt-get upgrade -qy
RUN apt-get install iptables redsocks curl man procps htop -qy
RUN curl -o java11.tar.gz -L https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7/OpenJDK11U-jre_x64_linux_hotspot_11.0.3_7.tar.gz
RUN tar -xzf java11.tar.gz
RUN rm java11.tar.gz
# ENV PATH="${PATH}:/app/jdk-11.0.3+7-jre/bin"
#keeping just java 8 on the path to avoid issues but still creating links as java8 and java11
RUN curl -o java8.tar.gz -L https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jre_x64_linux_hotspot_8u232b09.tar.gz
RUN tar -xzf java8.tar.gz
ENV PATH="${PATH}:/app/jdk8u232-b09-jre/bin"
RUN rm java8.tar.gz
RUN ln -s /app/jdk-11.0.3+7-jre/bin/java /usr/bin/java11
RUN ln -s /app/jdk8u232-b09-jre/bin/java /usr/bin/java8
ENV JAVA_HOME="/app/jdk8u232-b09-jre"
COPY redsocks.conf /etc/redsocks.conf
ENTRYPOINT /bin/bash scripts/client_config.sh
