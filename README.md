# Astrikos server setup

- `setup.sh` - To install all the required packages and setup the server.
    - Run `wget https://raw.githubusercontent.com/astrikos-sand/server-setup/master/setup.sh` to download the setup script
    - Run `chmod +x setup.sh` to make the script executable
    - Run `./setup.sh` to start the setup process

- `initial.sh` - To initialize the server
    - Run `wget https://raw.githubusercontent.com/astrikos-sand/server-setup/master/initial.sh` to download the script
    - Run `chmod +x initial.sh` to make the script executable
    - Run `./initial.sh` to start the initialization process
    - cd `./thingsboard` to go to the thingsboard directory
    - `tail -f thingsboard.log` to see the logs
    - If installation is successful, run the following command
        ```
        docker exec timescaledb psql -U postgres -c "CREATE DATABASE thingsboard;"
        cd ~/thingsboard/application/target/bin/install/
        export SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:5434/thingsboard"
        export JAVA_OPTS="-DSPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}"
        chmod +x install_dev_db.sh
        sudo -E ./install_dev_db.sh
        cd ~/thingsboard

        nohup java -jar application/target/thingsboard-3.6.4-boot.jar > output.log 2>&1 &
        ```

- `backend.sh` - To update the backend server.
    - Run `wget https://raw.githubusercontent.com/astrikos-sand/server-setup/master/backend.sh` to download the backend script
    - Run `chmod +x backend.sh` to make the script executable
    - Run `./backend.sh` to apply changes to the backend server

- `thingsboard.sh` - To update the thingsboard server.
    - Run `wget https://raw.githubusercontent.com/astrikos-sand/server-setup/master/thingsboard.sh` to download the thingsboard script
    - Run `chmod +x thingsboard.sh` to make the script executable
    - Run `./thingsboard.sh` to apply changes to the thingsboard server
