#!/bin/bash

#extract the hadoop package to a specific location(default /usr/local)
rm -r /usr/local/hadoop
tar -zxf `pwd`/hadoop.master.tar.gz -C /usr/local
chown -R hadoop /usr/local/hadoop

#set the environment(~/.bashrc & /etc/profile)
echo -n "export JAVA_HOME=/usr/lib/jvm/" >> /home/hadoop/.bashrc
echo `rpm -qa|grep java-1.8.0-openjdk-1.8.0` >> /home/hadoop/.bashrc
echo "# Hadoop Environment Variables
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
" >> /home/hadoop/.bashrc
echo -n "export JAVA_HOME=/usr/lib/jvm/" >> /etc/profile
echo `rpm -qa|grep java-1.8.0-openjdk-1.8.0` >> /etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/lib/dt/jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib/rt.jar
export PATH=$PATH:$JAVA_HOME/bin
" >> /etc/profile

#format the hdfs and shutdown the firewall
hdfs namenode -format
systemctl stop firewalld.service
systemctl disable firewalld.service

#start the distributive node
echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.1   dblab' > /etc/hosts
echo -n `ifconfig|grep -A 1 wlp58s0|grep inet|awk '{print $2}'` >> /etc/hosts
echo '  Master' >> /etc/hosts
start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver
