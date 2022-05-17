### Kafka ###

# Create Topic
/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 \
--create --replication-factor 1 --partitions 2 --topic my-first-topic

# View Topic
/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --list

# Send Messages
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server broker:9092 --topic my-first-topic 
This is a message
This is another message
<Control-C to exit>

# Consume Messages
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:9092 --topic my-first-topic --from-beginning

# View Topic Details
/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --describe --topic my-first-topic

Topic: my-first-topic   TopicId: G63enlhBQ2-IreB-BahJSw PartitionCount: 2       ReplicationFactor: 1    
        Topic: my-first-topic   Partition: 0    Leader: 1001    Replicas: 1001  Isr: 1001
        Topic: my-first-topic   Partition: 1    Leader: 1001    Replicas: 1001  Isr: 1001
        
        Configs: segment.bytes=1073741824,max.message.bytes=2000000

# Relaunch Kafka Consumer with a Group
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:9092 \
--topic my-first-topic --from-beginning --group my-group

# View Consumer Group Details (in a separate terminal session)
/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server broker:9092 --describe --group my-group

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             
my-group        my-first-topic  0          2               2               0               
my-group        my-first-topic  1          3               3               0               

GROUP           CONSUMER-ID                                              HOST            CLIENT-ID
my-group        consumer-my-group-1-2cbbe3ea-ca1f-4bd2-bb20-3508f9fe81e9 /172.19.0.2     consumer-my-group-1
my-group        consumer-my-group-1-2cbbe3ea-ca1f-4bd2-bb20-3508f9fe81e9 /172.19.0.2     consumer-my-group-1

# Add another Consumer to the existing Group (again, in a separate terminal session)
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:9092 \
--topic my-first-topic --from-beginning --group my-group

# View Consumer Group Details again (in a separate terminal session)
/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server broker:9092 --describe --group my-group

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG
my-group        my-first-topic  0          2               2               0  
my-group        my-first-topic  1          3               3               0  

GROUP           CONSUMER-ID                                              HOST            CLIENT-ID
my-group        consumer-my-group-1-1e4ae0aa-2be1-4480-a93c-571d361efa8f /172.19.0.2     consumer-my-group-1
my-group        consumer-my-group-1-779d5073-fc61-4327-82d0-4b8af610861e /172.19.0.2     consumer-my-group-1

# Data retention configuration example (not something that is configured in our environment)
/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --describe --topic my-first-topic

Topic: my-first-topic	PartitionCount: 2	ReplicationFactor: 3	
	Topic: my-first-topic	Partition: 0	Leader: 1	Replicas: 1,2,3	Isr: 1,2,3
	Topic: my-first-topic	Partition: 1	Leader: 2	Replicas: 2,3,4	Isr: 2,3,4

    Configs: min.insync.replicas=2,segment.bytes=536870912,retention.ms=86400000,retention.bytes=1073741824

### Kafka Connect ###

# Install vim
apt-get update && apt-get install vim

# Create connector configuration file
{
  "name": "file-source",
  "config": {
    "connector.class": "org.apache.kafka.connect.file.FileStreamSourceConnector",
    "tasks.max": "1",
    "file": "/tmp/file-source.txt",
    "topic": "streams-plaintext-input"
  }
}

# Create Topic
/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 \
--create --replication-factor 1 --partitions 1 --topic streams-plaintext-input

# Create Source file
echo "first line of content" > /tmp/file-source.txt 
echo "another line" >> /tmp/file-source.txt

# Start the source connector
curl -X POST -H "Content-Type: application/json" http://localhost:8083/connectors --data "@file-connector.json"

# Verify the source connector
curl http://localhost:8083/connectors/file-source/

# Test the connector
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:9092 --topic streams-plaintext-input --from-beginning # run an additional consumer in a separate terminal session

echo "adding more content" >> /tmp/file-source.txt # run via the terminal session of the kafka-connect container 
