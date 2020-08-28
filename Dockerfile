# Download and install Matlab Compiler Runtime v9.8 (2020a)
#
# This docker file will configure an environment into which the Matlab compiler
# runtime will be installed and in which stand-alone matlab routines (such as
# those created with Matlab's deploytool) can be executed.
#
# See http://www.mathworks.com/products/compiler/mcr/ for more info.


#Configure node environment
#FROM node:lts-slim

#RUN mkdir -p /usr/src/app
#RUN npm install --silent

#WORKDIR /usr/src/app

#EXPOSE 3000

#CMD [ "npm", "start" ]



FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q update && \
    apt-get install -q -y --no-install-recommends \
	  xorg \
      unzip \
      wget \
      curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Install the MCR dependencies and some things we'll need and download the MCR
# from Mathworks -silently install it
RUN mkdir /mcr-install && \
    mkdir /opt/mcr && \
    cd /mcr-install && \
    wget -q http://ssd.mathworks.com/supportfiles/downloads/R2020a/Release/4/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2020a_Update_4_glnxa64.zip && \
    unzip -q MATLAB_Runtime_R2020a_Update_4_glnxa64.zip && \
    rm -f MATLAB_Runtime_R2020a_Update_4_glnxa64.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

# Configure environment variables for MCR
ENV LD_LIBRARY_PATH /opt/mcr/v98/runtime/glnxa64:/opt/mcr/v98/bin/glnxa64:/opt/mcr/v98/sys/os/glnxa64
ENV XAPPLRESDIR /opt/mcr/v98/X11/app-defaults


#Configur
#FROM node:lts-slim

#RUN mkdir -p /usr/src/app
#RUN npm install --silent

#WORKDIR /usr/src/app

#EXPOSE 3000

#CMD [ "npm", "start" ]
