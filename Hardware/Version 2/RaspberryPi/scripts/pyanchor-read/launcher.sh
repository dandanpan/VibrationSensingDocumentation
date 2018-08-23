#!/bin/sh
# launcher.sh
# navigate to home directory, then to this directory, then execute python script, then back home

cd /home/pi/Footstep/config/scripts/pyanchor-read
# sleep for 10 seconds to wait for arduino to properly power on
sleep 10
# make sure script runs in the background
sudo python readcom_anchor.py &

# force restart pm2 on launch
sudo pm2 resurrect
cd -;
