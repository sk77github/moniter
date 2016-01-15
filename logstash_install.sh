#安装 logstash  版本  2.1.1 

#自动化安装脚本
#!/bin/bash
cd /data/
wget https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.1.1-1.noarch.rpm
rpm -ivh logstash-2.1.1-1.noarch.rpm
rm -rf logstash-2.1.1-1.noarch.rpm

#安装测试成功与否测试命令
service logstash test

#配置文件目录 /etc/logstash/conf.d/xxxxx.conf
#配置文件参考文档网址 https://www.elastic.co/guide/en/logstash/current/index.html


#脚本配置成功后测试命令
service logstash configtest

#logstash 启动命令
service logstash start

#logstash 停止命令
service logstash stop
