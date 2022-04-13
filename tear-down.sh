#/usr/bin/bash

docker-compose -f consumers/docker-compose.yml down          # stop the consumers
docker-compose -f owm-producer/docker-compose.yml down       # stop open weather map producer
docker-compose -f twitter-producer/docker-compose.yml down   # stop twitter producer
docker-compose -f kafka/docker-compose.yml down              # stop zookeeper, broker, kafka-manager and kafka-connect services
docker-compose -f cassandra/docker-compose.yml down          # stop Cassandra
docker-compose -f data-vis/docker-compose.yml down           # stop data-vis service
