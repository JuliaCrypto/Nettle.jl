#!/bin/bash

sudo add-apt-repository ppa:staticfloat/julia-deps -y
sudo add-apt-repository ppa:staticfloat/julia${JULIAVERSION} -y
sudo apt-get update -qq -y
sudo apt-get install libpcre3-dev julia -y
