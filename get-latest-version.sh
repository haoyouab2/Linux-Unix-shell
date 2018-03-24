#!/bin/bash

#Author: Zhibin Li <08826794brmt@gmail.com>


#VARIABLES
default_path=/usr/local/hadoop
current_user=`printenv | sed -n 's/SUDO_USER=\(.*\)/\1/p'`

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
