#/usr/bin/bash

docker-compose -f cassandra/docker-compose.yml up -d
docker-compose -f kafka/docker-compose.yml up -d 
docker-compose -f owm-producer/docker-compose.yml up -d
docker-compose -f twitter-producer/docker-compose.yml up -d
docker-compose -f consumers/docker-compose.yml up -d
docker-compose -f data-vis/docker-compose.yml up -d
docker ps -a
