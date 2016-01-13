#!/bin/bash
cd /data/
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar -xf zookeeper-3.4.6.tar.gz  -C /data/ && rm -rf zookeeper-3.4.6.tar.gz
mv zookeeper-3.4.6 zookeeper
cd /data/zookeeper && mkdir zookeeper-log
cd /data/zookeeper/conf && cp zoo_sample.cfg zoo.cfg
