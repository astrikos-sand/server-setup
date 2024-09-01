# Enable sudo
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi

cd
cd thingsboard
git pull origin release-3.6
nohup make prod-up > thingsboard.log 2>&1 &
