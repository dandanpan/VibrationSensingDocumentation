#!/bin/bash

# Installer script
# Let's start by installing dependencies

# start from clean repository
git checkout .

# make sure packages are upto date
sudo apt-get update

sudo apt-get -y --force-yes install nodejs nodejs-legacy npm vim
sudo apt-get -y --force-yes install openssh-server autossh
sudo npm install -g pm2

# run the deployment scripts
/bin/bash ./deploy.sh
