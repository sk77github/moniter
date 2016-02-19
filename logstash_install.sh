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
