# Enable sudo
sudo echo "sudo enabled"

# Prompt for confirmation to run the script
read -p "Do you want to run the script? (yes/no) " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Script execution cancelled"
    exit 1
fi

cd
cd flow-monorepo
git pull origin master
git submodule update --init --recursive
make prod-up
cd astrikos
make migrate
