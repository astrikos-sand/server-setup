read -p "Enter github token: " github_token

if [ -z "$github_token" ]; then
    echo "Github token cannot be empty"
    exit 1
fi

cd
# Enable sudo
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi

github_base_url="https://$github_token@github.com"

cd thingsboard
git pull origin release-3.6
make up

cd
cd astrikos-workspace
make up

cd

echo "Services updated"
