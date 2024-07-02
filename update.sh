cd
# Enable sudo
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi

cd thingsboard
git pull origin release-3.6
make prod-up > thingsboard.log 2>&1 &

cd

cd astrikos-workspace
git pull origin master
git submodule update --init --recursive
make prod-up > astrikos.log 2>&1 &

cd

echo "Services updated"
