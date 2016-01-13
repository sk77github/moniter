#!/bin/bash
cd /data/
wget https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.1.1-1.noarch.rpm
rpm -ivh logstash-2.1.1-1.noarch.rpm
rm -rf logstash-2.1.1-1.noarch.rpm
