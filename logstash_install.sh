#安装 logstash  版本  2.1.1 

#自动化安装脚本
#!/bin/bash
cd /data/ && mkdir logstash
wget https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.1.1-1.noarch.rpm
rpm -ivh logstash-2.1.1-1.noarch.rpm
rm -rf logstash-2.1.1-1.noarch.rpm

chown -R logstash:logstash /data/logstash/  #服务安装后修改目录权限

cat > /etc/sysconfig/logstash <<EOF
###############################
# Default settings for logstash
###############################

# Override Java location
#JAVACMD=/usr/bin/java

# Set a home directory
#LS_HOME=/var/lib/logstash

# Arguments to pass to logstash agent
#LS_OPTS=""

# Arguments to pass to java
LS_HEAP_SIZE="2000m"

# pidfiles aren't used for upstart; this is for sysv users.
#LS_PIDFILE=/var/run/logstash.pid

# user id to be invoked as; for upstart: edit /etc/init/logstash.conf
#LS_USER=logstash

# logstash logging
#LS_LOG_FILE=/var/log/logstash/logstash.log
#LS_USE_GC_LOGGING="true"

# logstash configuration directory
#LS_CONF_DIR=/etc/logstash/conf.d

# Open file limit; cannot be overridden in upstart
#LS_OPEN_FILES=16384

# Nice level
#LS_NICE=19

# If this is set to 1, then when stop is called, if the process has
# not exited within a reasonable time, SIGKILL will be sent next.
# The default behavior is to simply log a message program stop failed; still running
KILL_ON_STOP_TIMEOUT=0
EOF

#安装测试成功与否测试命令
service logstash test

#配置文件目录 /etc/logstash/conf.d/xxxxx.conf

#配置服务的目录 
######/etc/init.d/logstash#####
#LS_HOME=/data/logstash
#LS_LOG_DIR=/data/logstash


#配置文件参考文档网址 https://www.elastic.co/guide/en/logstash/current/index.html


#脚本配置成功后测试命令
service logstash configtest

#logstash 启动命令
service logstash start

#logstash 停止命令
service logstash stop




//shiper  配置  start
input {
    file {
        type => "testType"
        path => [ "/data/testLog/test.log*" ]
        exclude => [ "*.gz" ]
    }
}

output {
    if [type] == "testType" {
        kafka {
          codec => plain {
              format => "%{message}"
            }

          topic_id => "testLog"
          bootstrap_servers  => "100.106.15.1:9092, 100.106.15.2:9092, 100.106.15.3:9092"
          metadata_max_age_ms => 6000
        }
    }
}
//shiper  配置  end

//indexer  配置  start

input {
    kafka {
        topic_id => "testLog"
        zk_connect => "100.106.15.1:2181,100.106.15.2:2181,100.106.15.3:2181"
        group_id =>"testLogGroup"
        consumer_threads => 7
        codec => "plain"
    }
}

output {
   statsd {
    host => "100.106.15.9"
    port => 8125
    namespace => "logstash"
    increment => "laxin.exception"
  }
}
//shiper  配置  end


graphite 访问：
curl 100.106.15.7:8085/render?target=stats.logstash.host.laxin.exception\&from=-15min\&format=json



logstash添加字段：

filter{
     if [type] == "php-activity-exception" {
        grok {
            match => {"message" => "(?<timestamp>%{YEAR}-%{MONTHNUM}-%{MONTHDAY}%{SPACE}%{HOUR}:?%{MINUTE}(?::?%{SECOND}))%{SPACE}\[(%{SYSLOGHOST:ip}|-)\]\[\-\]\[\-\]\[%{LOGLEVEL:log_level}\]\[(?<classname>.*?)\]%{SPACE}(?<content>(.|\r|\n)*)"}
        }
        date {
            match => [ "timestamp" , "YYYY-MM-DD hh:mm:ss" ]
        }
    }
}
添加了message字段和timestamp字段，以及ip字段，log_level字段,classname字段，content字段

 filter {
     if [type] == "op-trade" or [type] == "op-payment"  {
         if [status] == "0" {
             mutate {
                 add_field => ["human_status", "ok"]
             }
         }
         else {
             mutate {
                 add_field => ["human_status", "fail"]
             }
         }
     }
 
  }
添加了human_status字段



input：
大多数input插件都会配置的configuration options：type
Value type is string
There is no default value for this setting.
Add a type field to all events handled by this input.
Types are used mainly for filter activation.
The type is stored as part of the event itself, so you can also use the type to search for it in Kibana.
If you try to set a type on an event that already has one (for example when you send an event from a shipper to an indexer) 
then a new input will not override the existing type. A type set at the shipper stays with that event for its life even 
when sent to another Logstash server.

插件列表
file：
By default, each event is assumed to be one line. If you would like to join multiple log lines into one event, 
you’ll want to use the multiline codec or filter.
例如：
 codec => multiline {
            pattern => "^\["
            negate => true
            what => "previous"
        }
把当前行的数据添加到前面一行后面，，直到新进的当前行匹配 ^\[ 正则为止。
The plugin keeps track of the current position in each file by recording it in a separate file named sincedb. 
file input 例子：
input {
    file {
        type => "testType"
        path => [ "/data/testLog/test.log*" ]
    }
}
file input 配置项：
start_positionedit
Value can be any of: beginning, end
Default value is "end"
Choose where Logstash starts initially reading files: at the beginning or at the end. 
The default behavior treats files like live streams and thus starts at the end. 
If you have old data you want to import, set this to beginning.
This option only modifies "first contact" situations where a file is new and not seen before,
i.e. files that don’t have a current position recorded in a sincedb file read by Logstash.
If a file has already been seen before, this option has no effect and the position recorded in the sincedb file will be used.

kafka:
This input will read events from a Kafka topic. It uses the high level consumer API provided by Kafka to read messages from the broker.
It also maintains the state of what has been consumed using Zookeeper. The default input codec is json
Ideally you should have as many threads as the number of partitions for a perfect balance 
more threads than partitions means that some threads will be idle
 kafka {
        topic_id => "nginxlog"
        zk_connect => "100.xxx.xxx.xxx:2181,100.xxx.xxx.xxx:2181,100.xxx.xxx.xxx:2181"
        group_id =>"nginxlogGroup"
        consumer_threads => 3
        codec => "plain"
    }


output:

kafka:
Write events to a Kafka topic. This uses the Kafka Producer API to write messages to a topic on the broker.
The only required configuration is the topic name. The default codec is json, so events will be persisted on the broker in json format.
If you select a codec of plain, Logstash will encode your messages with not only the message but also with a timestamp and hostname. 
If you do not want anything but your message passing through, you should make the output configuration something like:
    output {
      kafka {
        codec => plain {
           format => "%{message}"
        }
        bootstrap_servers => "xxx.xxx.xxx.3:9092, xxx.xxx.xxx.3:9092, xxx.xxx.xxx.3:9092"
        topic_id => "log4jlog"
      }
    }
For more information see http://kafka.apache.org/documentation.html#theproducer
Kafka producer configuration: http://kafka.apache.org/documentation.html#newproducerconfigs


Codec:
    
plain:
The "plain" codec is for plain text with no delimiting between events.
This is mainly useful on inputs and outputs that already have a defined framing in their transport protocol (such as 
zeromq, rabbitmq, redis, etc)

multiline:
The original goal of this codec was to allow joining of multiline messages from files into a single event. For example, 
joining Java exception and stacktrace messages into a single event.
The config looks like this:
input {
  stdin {
    codec => multiline {
      pattern => "pattern, a regexp"
      negate => "true" or "false"
      what => "previous" or "next"
    }
  }
}
