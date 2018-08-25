# Kafka with docker-compose

Three broker Kafka cluster and three node Zookeeper ensemble running in Docker with docker-compose.


## Usage

To start the Zookeeper ensemble and Kafka cluster, assuming you have docker-compose (>= 1.6) installed:

1. Change the `KAFKA_ADVERTISED_HOST_NAME` to your `DOCKER_HOST` IP
    Note: If you're using [Docker toolbox](https://www.docker.com/products/docker-toolbox) then this is the IP from `env | grep DOCKER_HOST`

2. design flow in the nifi


producer of rabbitmq

    e.user.created
    35.238.231.xx
    q.user.created

consumer of rabbitmq

    q.user.created
    35.238.231.xx
    guest/guest

consumer of kafka

    bootstrap.kafka:9092
    test-produce-consume
    
# nifi web management
http://35.188.63.xx:8080/nifi/

# kafka web management
http://35.202.170.xx

# rabbitmq web management
http://35.238.231.xx:15672
username: guest
password: guest