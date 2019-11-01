# network-monitor
Tool for inspecting HTTP/HTTPS network traffic through a transparent proxy

## Motivation

Debugging network issues can be challening. A common way to get a better insight about application network issues is to run the application through a proxy. While many applications and libraries respect some form of global proxy properties (environment, program options etc.) there are always some that don't (ie. Webflux). This poses a problem. In addition to that, setting up proxies can be annoying to do (ie. configuration of multiple applications to accept proxy certificates) and many times not a solution that is easy to share with co-workers (you end up needing yet another one step by step doc/wiki). This project is meant to simplify a lot of that and make it sharable. It is setup for java 8 and 11 but and firefox browser but it can be easily adapted/expanded for others. It also contains simple scripts for the lazy (you mostly get terminal completion power with them)

## Components
* Client 
    * where your app will run from
* Proxy 
    * capture all outgoing HTTP/HTTPS requests from client
* Browser 
    * optional browser from within the network which allows access to client code by using  client's domain name "client" instead of "localhost" (domain name may be configured in the docker-compose file)

## Caveat

The proxy will not be able to process localhost requests if you use your system browser (not the conteinerized one). If you attempt to make localhost request you will notice that they are not recorded by the proxy. That is because the proxy can't route a request that is sent to 127.0.0.1 which is local to itself. This is the reason for the containerized browser provided which should allow you to replace any instance of "localhost" with "client" due to the internal network dns. This works because "client" is resolved to an ip other than 127.0.0.1 within the internal network and the proxy can process the request as intended.

## Pre-requisites

You should have both docker and docker-compose installed. For the browser (otpional) you need to have support for X11 (should be present on Linux, Xquartz for Mac and Xming for Windows).

## Running

* Clone this project
* On a terminal window go to the cloned project folder
* Run "./start_containers.sh" and wait until the containers are built up and running
* If you have support for X11 you should be able to see a firefox browser open up. Otherwise you can use any other browser but you will need to import certificates from folder mitmproxy.
* Navigate to "http://localhost:8081" and verify that the verification requests have gone through

## Interacting With The Proxy

On a different terminal window run "./open_client_terminal.sh". That should get you in the context of the client container any outgoing connections from this container using should be registered or interceptable by the proxy (exception being port 8052 where the proxy runs). You may test it out by running curl requests (they should show up in http://localhost:8081). 

For HTTPS requests you may need to install the certificates into the programs that will be making requests or use -k flag with curl. For this project java was already setup to work with both http and https by installing the proxy's certificates in the java cacerts (see client_config.sh for an example). Proxy certificates should be in folder "mitmproxy" inside the container. A docker volume is setup to link folder "application" (in the same directory as the docker-compose.yml file) to folder /app/files inside the client container. 

You may also have to edit the ports exposed on the client container depending on what ports your application expects to use.

This setup uses mitmproxy but this approach should also work with other proxys. For more information about mitmproxy see https://docs.mitmproxy.org/stable/tools-mitmweb/

To rebuild run "./recreate_containers.sh"

To close containers run "./stop_containers.sh"

## How it Works

This setup is based on using docker to create an internal network with two containers. Docker compose puts those containers automatically in the same network. The client uses iptables firewall rules that redirect outgoing traffic to a local port which is then redirected to the proxy using Redsocks. Iptables are not recommended to use domain/host names since it may not work as expected (and they tend to be specific on both host and port combination) and that is the reason for using iptables in combination with Redsocks to route traffic to the proxy. 
