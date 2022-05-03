## Runbook (Day 1)

## EC2 Internet-Facing Machine (Amazon Linux 2)

## Install Git
```
sudo yum update -y
sudo yum install git -y
git version
```

## Install Docker & Docker-Compose
```
sudo yum update -y
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo pip3 install docker-compose
sudo reboot
```

Verification
```
sudo systemctl status docker.service
docker version
docker-compose version
```

## Get the code
Download the content of this Git repository onto your machine by running  

```bash
git clone -b day-1 --single-branch https://github.com/moritz91/zilina.git data-streaming-pipeline
```

Authentication
```
Username: moritz91
Password: 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
```

## Create docker network
```bash
$ docker network create cassandra-network                     # create a new docker network for cassandra. (kafka connect will exist on this network as well in addition to kafka-network)
```

## Starting Cassandra
Cassandra is setup so it runs keyspace and schema creation scripts at first setup so it is ready to use.

```bash
$ docker-compose -f cassandra/docker-compose.yml up -d
```

```bash
$ docker ps -a                                                # sanity check to make sure service is up
```

## Teardown
To stop the cassandra service run

```bash
$ docker-compose -f cassandra/docker-compose.yml down          # stop Cassandra
```

To remove the docker network

```bash
$ docker network rm cassandra-network
```

## Accessing Cassandra
First login into Cassandra's container with the following command

```bash
$ docker exec -it cassandra bash
```
Once logged in, bring up cqlsh with this command and query twitterdata and weatherreport tables like this:

```bash
$ cqlsh --cqlversion=3.4.5 127.0.0.1 			# make sure you use the correct cqlversion
```

And that's it! You are now connected to the Cassandra database as anonymous user.

## Connect to a running container
```bash
docker exec -it <container_name>
```

