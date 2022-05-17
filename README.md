## Runbook (Day 2)

## Get the code
Download the content of this Git repository onto your machine by running
```bash
git remote set-branches --add origin day-2
git fetch origin day-2
git checkout day-2
````

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
Kafka frontend is available at http://localhost:9000

> Kafka-Connect REST interface is available at http://localhost:8083

## Starting Producers
```bash
$ docker-compose -f owm-producer/docker-compose.yml up -d     # start the producer that retrieves open weather map
$ docker-compose -f twitter-producer/docker-compose.yml up -d # start the producer for twitter
```

## Starting Consumers
- Twitter classifier 
- Weather consumer for CSV dumps
```bash
$ docker-compose -f consumers/docker-compose.yml build        # this step is always required to apply new changes
```
```bash
$ docker-compose -f consumers/docker-compose.yml up -d        # start the consumers
```

```bash
$ docker-compose -f data-vis/docker-compose.yml up -d         # start the web app for data visualization 
```

## Check all containers are running with
```bash
$ docker ps -a                                                # sanity check to make sure services are up: kafka_broker_1, kafka-manager, zookeeper, kafka-connect service
```

## Access the Jupyter Notebook at
```bash
http://{machine-ip}.eu-central-1.compute.amazonaws.com:8889
```

## Teardown
To stop all running kakfa cluster services

```bash
$ docker-compose -f consumers/docker-compose.yml down         # stop the consumers
$ docker-compose -f owm-producer/docker-compose.yml down      # stop open weather map producer
$ docker-compose -f twitter-producer/docker-compose.yml down  # stop twitter producer
$ docker-compose -f kafka/docker-compose.yml down             # stop zookeeper, broker, kafka-manager and kafka-connect services
$ docker-compose -f cassandra/docker-compose.yml down         # stop cassandra
$ docker-compose -f data-vis/docker-compose.yml down          # stop jupyter notebook
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
cqlsh> use kafkapipeline;				 # keyspace name
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

