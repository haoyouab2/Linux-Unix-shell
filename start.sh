#!/bin/bash
echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.1   dblab' > /etc/hosts
echo -n `ifconfig|grep -A 1 wlp58s0|grep inet|awk '{print $2}'` >> /etc/hosts
echo '	Master' >> /etc/hosts
echo '192.168.1.109   Slave1' >> /etc/hosts
start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

