#!/bin/bash
sudo dnf install java-17-amazon-corretto -y
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar xzf kafka_2.13-3.6.0.tgz
cd kafka_2.13-3.6.0

# Get Public IP
PUBLIC_IP=$(curl http://checkip.amazonaws.com)

# Configure Advertised Listeners
sed -i "s|#advertised.listeners=PLAINTEXT://your.host.name:9092|advertised.listeners=PLAINTEXT://$PUBLIC_IP:9092|g" config/server.properties
sed -i "s|listeners=PLAINTEXT://:9092|listeners=PLAINTEXT://0.0.0.0:9092|g" config/server.properties

# Start Zookeeper (Daemon)
bin/zookeeper-server-start.sh -daemon config/zookeeper.properties

# Start Kafka (Daemon)
bin/kafka-server-start.sh -daemon config/server.properties
