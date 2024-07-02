#!/bin/bash

# Redirect stdout and stderr to both console and log file
exec > >(tee -i "setup.log") 2>&1

# region scripts/config.sh

# Constants
server_name="sand" # :)
backend_repo="anand817/astrikos-workspace"
thingsboard_repo="photon0205/thingsboard"
nginx_url="https://raw.githubusercontent.com/nik-55/astrikos-server-setup/master/astrikos.conf"

# Prompt user for github token
read -p "Enter github token: " github_token

if [ -z "$github_token" ]; then
    echo "Github token cannot be empty"
    exit 1
fi

# Enable sudo
cd
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi
# endregion scripts/config.sh

# region scripts/install.sh
# Update and upgrade the system
sudo apt update -y
sudo apt upgrade -y
sudo apt-get update -y
sudo apt-get upgrade -y

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
git config --global user.name "$server_name"

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
sudo apt install maven -y

# endregion scripts/install.sh

# region scripts/shell.sh

# Beautify the bash prompt
ps1_var="PS1='\[\e[92m\]\u@${server_name}\[\e[0m\]:\[\e[91m\]\w\\$\[\e[0m\] '"
echo "" >> "$HOME/.bashrc"
echo "# Custom configuration" >> "$HOME/.bashrc"
echo "$ps1_var" >> "$HOME/.bashrc"

# endregion scripts/shell.sh

# region scripts/iam.sh
sudo usermod -aG docker $USER

# endregion scripts/iam.sh

# region scripts/verify.sh
# Verify Installation

# snapd
if ! command -v snap &> /dev/null; then
  echo "snapd is not installed"
fi

# git
if ! command -v git &> /dev/null; then
  echo "git is not installed"
fi

# docker
if ! command -v docker &> /dev/null; then
  echo "docker is not installed"
fi

# nginx
if ! command -v nginx &> /dev/null; then
  echo "nginx is not installed"
fi

# Java 11
if ! command -v java &> /dev/null; then
  echo "Java 11 is not installed"
fi

# Maven
if ! command -v mvn &> /dev/null; then
  echo "Maven is not installed"
fi

# endregion scripts/verify.sh


echo "Setup script executed successfully"


# region project setup

github_base_url="https://$github_token@github.com"

# Thingsboard
git clone "$github_base_url/$thingsboard_repo"

# Workspace
git clone "$github_base_url/$backend_repo"

cd astrikos-workspace
git submodule update --init --recursive

cp ./astrikos/.env.sample ./astrikos/.env
cp ./astrikos-worker/.env.sample ./astrikos-worker/.env

cd

# Nginx
sudo curl -o "/etc/nginx/sites-available/astrikos.conf" "$nginx_url"
sudo ln -s /etc/nginx/sites-available/astrikos.conf /etc/nginx/sites-enabled/astrikos.conf
sudo nginx -t
sudo systemctl restart nginx

echo "Project setup completed successfully, please configure the .env files in the workspace folders"

# endregion project setup
