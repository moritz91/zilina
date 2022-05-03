#/usr/bin/bash

docker-compose  -f cassandra/docker-compose.yml up -d
docker-compose --env-file kafka/.env -f kafka/docker-compose.yml up -d
docker-compose --env-file owm-producer/.env -f owm-producer/docker-compose.yml up -d
docker-compose --env-file twitter-producer/.env -f twitter-producer/docker-compose.yml up -d
docker-compose --env-file consumers/.env -f consumers/docker-compose.yml up -d
docker-compose --env-file data-vis/.env -f data-vis/docker-compose.yml up -d

docker ps -a
