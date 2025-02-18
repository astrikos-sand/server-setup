cd /opt/astrikos

docker load -i astrikos_backend.tar
docker load -i astrikos_celery_beat.tar
docker load -i rabbitmq.tar
docker load -i timescale.tar
docker load -i astrikos_celery.tar
docker load -i astrikos_worker.tar
docker load -i postgres.tar
docker load -i astrikos_events.tar

docker volume create timescaledb

sudo tar -xvf timescaledb.tar -C /var/lib/docker/volumes/timescaledb/_data

cd /opt/astrikos/worker
docker compose -f setup.docker-compose.yml up --build -d

cd /opt/astrikos/flow-backend
docker compose -f setup.docker-compose.yml up --build -d

make migrate
make createsuperuser

cd /opt/astrikos

docker run -d \
  --name timescaledb \
  -p 5434:5432 \
  -e POSTGRES_PASSWORD=postgres \
  -v timescaledb:/home/postgres/pgdata \
  timescale/timescaledb-ha:pg16

docker run -d \
  --name thingsboard-broker \
  -p 15672:15672 \
  -p 5672:5672 \
  -e RABBITMQ_HOST=broker \
  -e RABBITMQ_DEFAULT_PORT=5672 \
  -e RABBITMQ_DEFAULT_USER=root \
  -e RABBITMQ_DEFAULT_PASS=root \
  --health-cmd="rabbitmqctl status" \
  --health-interval=5s \
  --health-retries=5 \
  --health-timeout=5s \
  rabbitmq:3.13.0-alpine

export SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:5434/thingsboard"
export JAVA_OPTS="-DSPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}"

nohup java -jar thingsboard.jar > thingsboard.log 2>&1 &
