## Runbook (Day 1)

## EC2 Internet-Facing Machine (Amazon Linux 2)

## Install Git
```
sudo yum update -y
sudo yum install git -y
git version
```

## Install Docker
```
sudo yum update
sudo yum search docker
sudo yum info docker
sudo yum install docker
```

## Install Docker-Compose
```
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
```

Verification
```
sudo systemctl status docker.service
docker version
docker-compose version
```

## Restart the machine
``reboot``

## Get the code
Download the content of this Git repository onto your datalake appliance by running:  
``git clone https://github.com/moritz91/zilina.git data-streaming-pipeline``

Authentication
```
Username: moritz91
Password: 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
```

## Create docker networks
```bash
$ docker network create kafka-network                         # create a new docker network for kafka cluster (zookeeper, broker, kafka-manager services, and kafka connect sink services)
$ docker network create cassandra-network                     # create a new docker network for cassandra. (kafka connect will exist on this network as well in addition to kafka-network)
```

## Starting Cassandra
Cassandra is setup so it runs keyspace and schema creation scripts at first setup so it is ready to use.

```bash
$ docker-compose -f cassandra/docker-compose.yml up -d
```

## Starting kafka on docker
```bash
$ docker-compose -f kafka/docker-compose.yml up -d            # start single zookeeper, broker, kafka-manager and kafka-connect services
$ docker ps -a                                                # sanity check to make sure services are up: kafka_broker_1, kafka-manager, zookeeper, kafka-connect service
```

> **Note:** 
Kafka front end is available at http://localhost:9000

> Kafka-Connect REST interface is available at http://localhost:8083

## Starting Producers
```bash
$ docker-compose -f owm-producer/docker-compose.yml up -d     # start the producer that retrieves open weather map
$ docker-compose -f twitter-producer/docker-compose.yml up -d # start the producer for twitter
```

## Starting Twitter classifier (plus Weather consumer for CSV dumps)
```bash
$ docker-compose -f consumers/docker-compose.yml build # this step is always required to apply new changes
```
Start consumers:
```bash
$ docker-compose -f consumers/docker-compose.yml up -d        # start the consumers
```

## Check all containers are running with
```bash
$ docker ps -a                                                # sanity check to make sure services are up: kafka_broker_1, kafka-manager, zookeeper, kafka-connect service
```

## Teardown
To stop all running kakfa cluster services

```bash
$ docker-compose -f consumers/docker-compose.yml down          # stop the consumers
$ docker-compose -f owm-producer/docker-compose.yml down       # stop open weather map producer
$ docker-compose -f twitter-producer/docker-compose.yml down   # stop twitter producer
$ docker-compose -f kafka/docker-compose.yml down              # stop zookeeper, broker, kafka-manager and kafka-connect services
$ docker-compose -f cassandra/docker-compose.yml down          # stop Cassandra
```

To remove the kafka-network network:

```bash
$ docker network rm kafka-network
$ docker network rm cassandra-network
```

## Check that data is arriving in Cassandra
First login into Cassandra's container with the following command or open a new CLI from Docker Desktop if you use that.

```bash
$ docker exec -it cassandra bash
```
Once logged in, bring up cqlsh with this command and query twitterdata and weatherreport tables like this:

```bash
$ cqlsh --cqlversion=3.4.5 127.0.0.1 			# make sure you use the correct cqlversion
cqlsh> use kafkapipeline;				# keyspace name
cqlsh:kafkapipeline> select * from twitterdata;
cqlsh:kafkapipeline> select * from weatherreport;
```

And that's it! You should be seeing records coming in on the Cassandra database.

## Load data utility
To load backup CSV files into Cassandra, from a console run the following:

```bash
$ python consumers/python/cassandrautils.py twitter get twitter.csv
$ python consumers/python/cassandrautils.py weather get weather.csv
```

## Connect to a running container
```bash
docker exec -it <container_name>
```

