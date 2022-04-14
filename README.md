## Runbook (Day 1)

## SSH into your Continental.datalake appliance
SSH is a protocol, that allows you to login to your appliance with a terminal. Your login name is your windows account. 
We recommend to use your terminal and your preinstalled ssh client for the purposes of this session. 
The IP address of your appliance can be obtained via the Continental.datalake website.

Open your terminal and run:  
``ssh "uiXXXXX@DATLAKE-APPLIANCE-IP"``

The datalake appliances allow exposing web-applications on a preconfigured port, which can be accessed using the following domain based on the appliance's ip address:  
``https://ip-DATALAKE-APPLIANCE-IP.datalake.u0.ww.conti.de/x-datalake/``

DATALAKE-APPLIANCE-IP format: 10-194-160-112

As part of our session today, we will run a jupyter notebook application on the appliance and expose it on port `8889`.
Therefore, the default port `9999` of the datalake appliances, which is used to expose web applications needs to be changed.

To do that, run the following commands in sequence:
```
sudo su - (switches to the root user)
vi /etc/nginx/x-datalake.conf (type :wq to write the editor's buffer to disk and quit to exit the editor)
update the port from 9999 to 8889
comment out the rewrite statement (append # to the line)
exit (switches back to your user)
```

## Get the code
Download the content of this Git repository onto your datalake appliance by running:  
``git clone https://github.geo.conti.de/uib05465/zilina.git data-streaming-pipeline``

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

(Alternatively you can build first, docker will do it anyway if it hasn't built it before, this step is required to apply new changes)
```bash
$ docker-compose -f consumers/docker-compose.yml build
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

## Check that data is arriving to Cassandra

First login into Cassandra's container with the following command or open a new CLI from Docker Desktop if you use that.
```bash
$ docker exec -it cassandra bash
```
Once loged in, bring up cqlsh with this command and query twitterdata and weatherreport tables like this:
```bash
$ cqlsh --cqlversion=3.4.4 127.0.0.1 #make sure you use the correct cqlversion

cqlsh> use kafkapipeline; #keyspace name

cqlsh:kafkapipeline> select * from twitterdata;

cqlsh:kafkapipeline> select * from weatherreport;
```

And that's it! you should be seeing records coming in to Cassandra. Feel free to play around with it by bringing down containers and then up again to see the magic of fault tolerance!

## Load data utility
To load backup CSV files into Cassandra, from a console run the following:

```bash
$ python consumers/python/cassandrautils.py twitter {PATH_TO_twitter.csv}
$ python consumers/python/cassandrautils.py weather {PATH_TO_weather.csv}
```

## FAQs

How can I connect to a running container?

```bash
docker exec -it <container_name>
```

