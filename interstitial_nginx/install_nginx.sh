#!/bin/bash
set -e
# This script should be run as root.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

apt install -y nginx

# configure nginx
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/default << EOM
server {
    listen 80;
    listen [::]:80;

    server_name meet.interstitial.coop;    

    location / {
        proxy_pass http://0.0.0.0:8000;
    }
}

server {
    listen 80;
    listen [::]:80;

    server_name mail.interstitial.coop;    

    location / {
        proxy_pass http://0.0.0.0:8001;
    }
}

EOM

service nginx start

# HTTPS
apt -y install software-properties-common
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt -y update

apt -y install certbot python-certbot-nginx
apt install -y certbot
apt install -y letsencrypt

echo "Starting certbot ssl cert installation."
echo "You will be required to answer manual prompts."
certbot --nginx
