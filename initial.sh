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
cd flow-monorepo/flow-backend
docker compose -f setup.docker-compose.yml up --build -d

make migrate
make createsuperuser
make seed

cd
cd flow-monorepo/worker
docker compose -f setup.docker-compose.yml up --build -d

echo "Services updated"
