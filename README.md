# network-monitor
Tool for inspecting HTTP/HTTPS network traffic through a transparent proxy

## Motivation

While using a newer but popular java library that does some network operations, I had issues related to its network operations. Tracking the code where the actual network requests was time consuming and request data was largely scattered. Normally in a situation like that running java through a proxy such as Fiddler would greatly help to debug such network issues. However, it turned out that the java library in question did not respect java system properties that should control proxy usage.

This project is meant to provide a setup for monitoring outgoing requests from any program (java or not) in a generic way through a transparent proxy even if proxy environment variables are not respected.

## Pre-requisites

You should have both docker and docker-compose installed.

## Running

* Clone this project
* On a terminal window go to the cloned project folder
* Run "docker-compose up" and wait until the containers are built up and running
* Open browser on page "http://localhost:8081" and verify that the verification requests have gone through

## Interacting With The Proxy

On a different terminal window run "docker exec -ti client /bin/bash". That should get you in the context of the client container any outgoing connections from this container using port 80 or 443 should be registered or interceptable by the proxy (more ports can be configured by editting run.sh). You may test it out by running curl requests (they should show up in http://localhost:8081). For HTTPS requests you may need to install the certificates into the programs that will be making requests or use -k flag with curl. For this project java was already setup to work with both http and https by installing the proxy's certificates in the java cacerts (see run.sh for an example). Proxy certificates should be in folder "mitmproxy" inside the container. A docker volume is setup to link folder application (in the same directory as the docker-compose.yml file) to folder /app/files inside the client container. 

You may also have to edit the ports exposed on the client container depending on what ports your application expects to use.

This setup uses mitmproxy but this approach should also work with other proxys. For more information about mitmproxy see https://docs.mitmproxy.org/stable/tools-mitmweb/

## How Works

This setup is based on using docker to create an internal network with two containers. Docker compose puts those containers automatically in the same network. The client uses iptables firewall rules that redirect outgoing traffic to a local port which is then redirected to the proxy using Redsocks. Iptables are not recommended to use domain/host names since it may not work as expected and that is the reason for using iptables in combination with Redsocks to route traffic to the proxy. 
