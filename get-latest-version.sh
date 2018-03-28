#!/bin/bash

#Author: Zhibin Li <08826794brmt@gmail.com>


#VARIABLES
default_path=/usr/local/hadoop
current_user=`printenv | sed -n 's/SUDO_USER=\(.*\)/\1/p'`
java_path=/usr/lib/jvm/`rpm -qa | grep java-1.8.0-openjdk-1.8.0`

if [ $UID -ne 0 ]; then
	echo 'need to run as root'
	exit 1
fi

echo -n "Enter directory in which to extract the package (/usr/local/hadoop): "
read hadoop_path
HADOOP_HOME=${hadoop_path:-$default_path}

#download the latest version of hadoop
wget http://mirror.bit.edu.cn/apache/hadoop/common/current/\
`curl -s http://mirror.bit.edu.cn/apache/hadoop/common/current/| \
sed -n 's/.*\(hadoop-.*.tar.gz\).*/\1/p'| \
grep -v src` -O hadoop.tar.gz

#extract to HADOOP_HOME
rm -rf $HADOOP_HOME
mkdir $HADOOP_HOME
tar -zxf hadoop.tar.gz -C $HADOOP_HOME --strip-components=1
rm -rf hadoop.tar.gz
chown -R $current_user:$current_user $HADOOP_HOME


#set the environment(~/.bashrc & /etc/profile)
#java path
echo "export JAVA_HOME=$java_path
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib/rt.jar
export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
#hadoop path
echo "#Hadoop Environment Variables
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /home/$current_user/.bashrc

#configure the file in hadoop
