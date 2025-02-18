#!/bin/bash

# Redirect stdout and stderr to both console and log file
exec > >(tee -i "setup.log") 2>&1

# region scripts/config.sh

# Constants
nginx_url="https://raw.githubusercontent.com/astrikos-sand/server-setup/master/astrikos.conf"
backend_nginx_url="https://raw.githubusercontent.com/astrikos-sand/server-setup/master/backend.conf"
ip_address="13.201.128.76"


mkdir -p /opt/astrikos

# Enable sudo
cd /opt/astrikos
sudo echo "sudo enabled"

# region scripts/install.sh
# Update and upgrade the system
sudo apt update -y
sudo apt-get update -y

# Utilities
sudo apt install coreutils -y
sudo apt install build-essential -y
sudo apt install wget -y
sudo apt install curl -y
sudo apt-get install unzip -y

# Snapd
sudo apt install snapd -y

# Git
sudo apt install git -y

# Docker
sudo apt-get update -y
sudo apt-get install ca-certificates -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Nginx
sudo apt install nginx -y

# Install Java 11 for Thingsboard
sudo apt install openjdk-11-jdk -y

sudo usermod -aG docker $USER


echo "Setup script executed successfully"


# region project setup

git clone https://github.com/astrikos-sand/worker.git
git clone https://github.com/astrikos-sand/flow-backend.git

cp ./worker/.env.setup ./worker/.env
cp ./flow-backend/.env.setup ./flow-backend/.env

cd /opt/astrikos/

# Nginx
sudo curl -o "/etc/nginx/sites-available/astrikos.conf" "$nginx_url"
sudo curl -o "/etc/nginx/sites-available/backend.conf" "$backend_nginx_url"
sudo ln -s /etc/nginx/sites-available/astrikos.conf /etc/nginx/sites-enabled/astrikos.conf
sudo ln -s /etc/nginx/sites-available/backend.conf /etc/nginx/sites-enabled/backend.conf

wget http://"$ip_address"/astrikos_backend.tar
wget http://"$ip_address"/astrikos_celery_beat.tar
wget http://"$ip_address"/rabbitmq.tar
wget http://"$ip_address"/timescale.tar
wget http://"$ip_address"/astrikos_celery.tar
wget http://"$ip_address"/astrikos_worker.tar
wget http://"$ip_address"/postgres.tar
wget http://"$ip_address"/astrikos_events.tar

wget http://"$ip_address"/timescaledb.tar
wget http://"$ip_address"/thingsboard.jar


echo "Project setup completed successfully"

# endregion project setup
