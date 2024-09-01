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
nohup make prod-up-new > thingsboard.log 2>&1 &

cd
cd flow-monorepo
make prod-up
make migrate
make createsuperuser

echo "Services updated"
