#安装 zookeeper  版本 3.4.6 

#自动化安装脚本
#!/bin/bash
cd /data/
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar -xf zookeeper-3.4.6.tar.gz  -C /data/ && rm -rf zookeeper-3.4.6.tar.gz
mv zookeeper-3.4.6 zookeeper
cd /data/zookeeper && mkdir zookeeper-log
cd /data/zookeeper/conf && cp zoo_sample.cfg zoo.cfg

#目标位置
/data/zookeeper

#安装测试成功与否测试命令
/data/zookeeper/bin/zkServer.sh

#配置文件目录 /data/zookeeper/conf/zoo.cfg
#配置文件参考文档网址 http://zookeeper.apache.org/doc/trunk/zookeeperStarted.html

#自动化配置脚本
cat > /data/zookeeper/conf/zoo.cfg <<EOF
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=/data/zookeeper/zookeeper-log
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
#
EOF

echo "set /data/zookeeper/zookeeper-log/myid command is echo "id" > /data/zookeeper/zookeeper-log/myid"

#启动需要做的工作
1)
	echo id > /data/zookeeper/zookeeper-log/myid
	id 为集群中的唯一的id 数字形式 
	
2) 配置整个集群的实例 形式是 server.id=ip:2888:3888 其中的id为上面的形式
	server.1=100.106.15.1:2888:3888
	server.2=100.106.15.2:2888:3888
	server.3=100.106.15.3:2888:3888


#zookeeper 启动命令
/data/zookeeper/bin/zkServer.sh start

#zookeeper 停止命令
/data/zookeeper/bin/zkServer.sh stop



#安装 kafka  版本 kafka_2.11-0.9.0.0 

#自动化安装脚本
#!/bin/bash
cd /data  
wget http://apache.fayea.com/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz
tar -xf kafka_2.11-0.9.0.0.tgz -C /data/ && rm -rf kafka_2.11-0.9.0.0.tgz
mv kafka_2.11-0.9.0.0 kafka
cd /data/kafka/ && mkdir kafka-logs


#配置文件目录 /data/kafka/config/server.properties
#配置文件参考文档网址 http://kafka.apache.org/documentation.html#configuration
#自动化配置脚本
cat > /data/kafka/config/server.properties <<EOF
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# see kafka.server.KafkaConfig for additional details and defaults

############################# Server Basics #############################

# The id of the broker. This must be set to a unique integer for each broker.
broker.id=6

############################# Socket Server Settings #############################

listeners=PLAINTEXT://:9092

# The port the socket server listens on
port=9092

# Hostname the broker will bind to. If not set, the server will bind to all interfaces
host.name=100.106.15.6

# Hostname the broker will advertise to producers and consumers. If not set, it uses the
# value for "host.name" if configured.  Otherwise, it will use the value returned from
# java.net.InetAddress.getCanonicalHostName().
advertised.host.name=100.106.15.6

# The port to publish to ZooKeeper for clients to use. If this is not set,
# it will publish the same port that the broker binds to.
#advertised.port=<port accessible by clients>

# The number of threads handling network requests
num.network.threads=3
 
# The number of threads doing disk I/O
num.io.threads=8

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600


############################# Log Basics #############################

# A comma seperated list of directories under which to store log files
log.dirs=/data/kafka/kafka-logs

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
num.partitions=1

# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1

#user can delete topic
delete.topic.enable=true

############################# Log Flush Policy #############################

# Messages are immediately written to the filesystem but by default we only fsync() to sync
# the OS cache lazily. The following configurations control the flush of data to disk. 
# There are a few important trade-offs here:
#    1. Durability: Unflushed data may be lost if you are not using replication.
#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.
#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to exceessive seeks. 
# The settings below allow one to configure the flush policy to flush data after a period of time or
# every N messages (or both). This can be done globally and overridden on a per-topic basis.

# The number of messages to accept before forcing a flush of data to disk
#log.flush.interval.messages=10000

# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion
log.retention.hours=168

# A size-based retention policy for logs. Segments are pruned from the log as long as the remaining
# segments don't drop below log.retention.bytes.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according 
# to the retention policies
log.retention.check.interval.ms=300000

# By default the log cleaner is disabled and the log retention policy will default to just delete segments after their retention expires.
# If log.cleaner.enable=true is set the cleaner will be enabled and individual logs can then be marked for log compaction.
log.cleaner.enable=false

############################# Zookeeper #############################

# Zookeeper connection string (see zookeeper docs for details).
# This is a comma separated host:port pairs, each corresponding to a zk
# server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
# You can also append an optional chroot string to the urls to specify the
# root directory for all kafka znodes.
#zookeeper.connect=localhost:2181

# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=6000
EOF

echo "set  [/data/kafka/config/server.properties] param broker.id host.name=ip,advertised.host.name=ip"


#启动需要做的工作
	 broker.id=id  # id 为集群中的唯一的id 数字形式 
	 host.name=ip  # ip 为当前机器ip
	 advertised.host.name=ip # ip 为当前机器ip
	 zookeeper.connect=localhost:2181 #配置上zookeeper的集群中的实例 zookeeper.connect=100.106.15.1:2181,100.106.15.2:2181,100.106.15.3:2181,100.106.15.6:2181
	 
#kafka 启动命令
/data/kafka/bin/kafka-server-start.sh -daemon /data/kafka/config/server.properties

#kafka 停止命令
/data/kafka/bin/kafka-server-stop.sh 

#kafka 查看所有topic
/data/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --list

#创建topic命令
/data/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor M --partitions N --topic topicName
#命令说明 
  M 为该topic创建的备份数据份数  允许出错的节点为 M - 1 
  N 为该topic的分区的个数 
  name topic的名字

#删除topic命令 *****谨慎使用***** 
/data/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --delete --topic topicName


#消费topic数据
/data/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic topicName

#查看topic的偏移量
/data/kafka/bin/kafka-consumer-offset-checker.sh --zookeeper localhost:2181 --group GroupName --topic topicName

