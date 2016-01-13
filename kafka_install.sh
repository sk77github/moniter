#!/bin/bash
cd /data  
wget http://apache.fayea.com/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz
tar -xf kafka_2.11-0.9.0.0.tgz -C /data/ && rm -rf kafka_2.11-0.9.0.0.tgz
mv kafka_2.11-0.9.0.0 kafka
cd /data/kafka/ && mkdir kafka-logs
