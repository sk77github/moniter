rpm安装目录拓扑：
https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-dir-layout.html

rpm -ivh elasticsearch-2.3.4.rpm 
warning: elasticsearch-2.3.4.rpm: Header V4 RSA/SHA1 Signature, key ID d88e42b4: NOKEY
Preparing...                ########################################### [100%]
Creating elasticsearch group... OK
Creating elasticsearch user... OK
   1:elasticsearch          ########################################### [100%]
### NOT starting on installation, please execute the following statements to configure elasticsearch service to start automatically using chkconfig
 sudo chkconfig --add elasticsearch
### You can start elasticsearch service by executing
 sudo service elasticsearch start
 
 
#修改 /etc/elasticsearch/elasticsearch.yml
  node.name=xxxx 集群中某个结点的名称
#集群如何发现节点 该版本为单播的形式
  discovery.zen.ping.unicast.hosts: ["192.168.1.10", "192.168.1.11"]
#修改可用最大内存 /etc/sysconfig/elasticsearch
  ES_HEAP_SIZE=xxxx  #最大不超过32G 
 
  
#启动命令
 service elasticsearch start
#停止命令
 service elasticsearch stop



-----------------------------------------------------------------------------------------------------

#安装 elasticsearch 版本 2.1.1 方式 RPM
#自动化安装脚本
#!/bin/bash
#cd /data/
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.1.1/elasticsearch-2.1.1.rpm
rpm -ivh elasticsearch-2.1.1.rpm
rm -rf elasticsearch-2.1.1.rpm
chkconfig --add elasticsearch
cd /data && mkdir elasticsearch 
cd /data/elasticsearch && mkdir elasticsearch_data && mkdir && mkdir elasticsearch_log
chown -R elasticsearch:elasticsearch /data/elasticsearch/

#####/etc/elasticsearch/elasticsearch.yml####
#自动化配置文件脚本

cat > /etc/elasticsearch/elasticsearch.yml <<EOF  
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please see the documentation for further information on configuration options:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration.html>
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
 cluster.name: elk-monitor 
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
# node.name: node-6
#
# Add custom attributes to the node:
#
# node.rack: r1
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
# path.data: /path/to/data
#
# Path to log files:
#
# path.logs: /path/to/logs
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
# bootstrap.mlockall: true
#
# Make sure that the "ES_HEAP_SIZE" environment variable is set to about half the memory
# available on the system and that the owner of the process is allowed to use this limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
# 
 network.host: xxx.xxx.xxx.xxx
#
# Set a custom port for HTTP:
#
 http.port: 9200
#
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html>
#
# ---------------------------------- Gateway -----------------------------------
#
# Block initial recovery after a full cluster restart until N nodes are started:
#
# gateway.recover_after_nodes: 3
#
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-gateway.html>
#
# --------------------------------- Discovery ----------------------------------
#
# Elasticsearch nodes will find each other via unicast, by default.
#
# Pass an initial list of hosts to perform discovery when new node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
 discovery.zen.ping.unicast.hosts: ["host1", "host2"]
#
# Prevent the "split brain" by configuring the majority of nodes (total number of nodes / 2 + 1):
#
# discovery.zen.minimum_master_nodes: 3
#
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html>
#
# ---------------------------------- Various -----------------------------------
#
# Disable starting multiple nodes on a single system:
#
# node.max_local_storage_nodes: 1
#
# Require explicit names when deleting indices:
#
# action.destructive_requires_name: true
EOF

############/etc/sysconfig/elasticsearch##########
##自动化配置脚本
cat > /etc/sysconfig/elasticsearch <<EOF
################################
# Elasticsearch
################################

# Elasticsearch home directory
ES_HOME=/usr/share/elasticsearch

# Elasticsearch configuration directory
CONF_DIR=/etc/elasticsearch

# Elasticsearch data directory
DATA_DIR=/data/elasticsearch/elasticsearch_data

# Elasticsearch logs directory
LOG_DIR=/data/elasticsearch/elasticsearch_log

# Elasticsearch PID directory
PID_DIR=/var/run/elasticsearch

# Heap size defaults to 256m min, 1g max
# Set ES_HEAP_SIZE to 50% of available RAM, but no more than 31g
ES_HEAP_SIZE=31g

# Heap new generation
#ES_HEAP_NEWSIZE=

# Maximum direct memory
#ES_DIRECT_SIZE=

# Additional Java OPTS
#ES_JAVA_OPTS=

# Configure restart on package upgrade (true, every other setting will lead to not restarting)
#ES_RESTART_ON_UPGRADE=true

# Path to the GC log file
ES_GC_LOG_FILE=/data/elasticsearch/elasticsearch_log/gc.log

################################
# Elasticsearch service
################################

# SysV init.d
#
# When executing the init script, this user will be used to run the elasticsearch service.
# The default value is 'elasticsearch' and is declared in the init.d file.
# Note that this setting is only used by the init script. If changed, make sure that
# the configured user can read and write into the data, work, plugins and log directories.
# For systemd service, the user is usually configured in file /usr/lib/systemd/system/elasticsearch.service
ES_USER=elasticsearch
ES_GROUP=elasticsearch

# The number of seconds to wait before checking if Elasticsearch started successfully as a daemon process
ES_STARTUP_SLEEP_TIME=5

################################
# System properties
################################

# Specifies the maximum file descriptor number that can be opened by this process
# When using Systemd, this setting is ignored and the LimitNOFILE defined in
# /usr/lib/systemd/system/elasticsearch.service takes precedence
MAX_OPEN_FILES=65535

# The maximum number of bytes of memory that may be locked into RAM
# Set to "unlimited" if you use the 'bootstrap.mlockall: true' option
# in elasticsearch.yml (ES_HEAP_SIZE  must also be set).
# When using Systemd, the LimitMEMLOCK property must be set
# in /usr/lib/systemd/system/elasticsearch.service
#MAX_LOCKED_MEMORY=unlimited

# Maximum number of VMA (Virtual Memory Areas) a process can own
# When using Systemd, this setting is ignored and the 'vm.max_map_count'
# property is set at boot time in /usr/lib/sysctl.d/elasticsearch.conf
MAX_MAP_COUNT=262144
EOF

echo "set [/etc/elasticsearch/elasticsearch.yml] param node.name=xxxx manual"
echo "set [/etc/elasticsearch/elasticsearch.yml] discovery.zen.ping.unicast.hosts: ["192.168.1.10", "192.168.1.11"] manual"
echo "set [/etc/sysconfig/elasticsearch] param ES_HEAP_SIZE=xxxx manual"

-----------------------------------------------------------------------------------------------------------------------


#安装kibana 版本 4.3.1 
wget https://download.elastic.co/kibana/kibana/kibana-4.3.1-linux-x64.tar.gz
tar -xf kibana-4.3.1-linux-x64.tar.gz -C /data/ && rm -rf kibana-4.3.1-linux-x64.tar.gz
cd /data/ && mv kibana-4.3.1-linux-x64 kibana
