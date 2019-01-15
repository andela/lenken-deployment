# Create image based on the official Node 7 image from dockerhub
FROM debian:latest

USER root

RUN mkdir /var/app

# Change working directory
WORKDIR /var/app

# Update repositories
RUN apt-get update && apt-get install -y apt-utils

# Install https transport 
RUN apt-get install apt-transport-https -y

# Install gnupg2
RUN apt-get install gnupg2 -y

# Install java 8
RUN apt-get install openjdk-8-jdk -y
RUN apt-get install openjdk-8-jre -y

# Install wget 
RUN apt-get install wget


