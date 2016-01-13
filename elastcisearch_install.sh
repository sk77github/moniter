#!/bin/bash
cd /data/
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.1.1/elasticsearch-2.1.1.rpm
rpm -ivh elasticsearch-2.1.1.rpm
rm -rf elasticsearch-2.1.1.rpm

wget https://download.elastic.co/kibana/kibana/kibana-4.3.1-linux-x64.tar.gz
tar -xf kibana-4.3.1-linux-x64.tar.gz -C /data/ && rm -rf kibana-4.3.1-linux-x64.tar.gz
mv kibana-4.3.1-linux-x64 kibana
