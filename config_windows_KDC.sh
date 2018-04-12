#!/bin/bash
# This script is used to configure windows server as a KDC(Key Distribution Center).


Usage() {
cat <<END
Usage: config_windows_KDC.sh <KVM_HOST_IP>
END
}

if [ $# -ne 1 ]; then
	Usage
	exit 1
fi

# variables
KVM_HOST_IP=$1	# ip address of the host machine which runs kvm
VM_NAME="win2012r2"	# default vm guest name
AD_DC_IP=


# run the case /rhds/provision/beaker/windows-vm/ to set a windows AD DC
yum -y install ada-rhds-provision-beaker-windows-vm.noarch	# install the case
export VM_NAME
/mnt/tests/rhds/provision/beaker/windows-vm/make run	# the default path where the case is installed
AD_DC_IP=`ssh root@$KVM_HOST_IP \
cat /var/www/html/win2012r2.env | sed -n 's/VM_EXT_IP=\(.*\)/\1/p'`	# AD DC(Active Directory Domain Controller ip address)


# ssh to windows and setup the kdc service
# use expect script to login and configure
/usr/bin/expect <<-EOF
spawn bash -c "ssh Administrator@$AD_DC_IP \
-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
expect {
"*(yes/no)?" { send "yes\r"; exp_continue }
"Administrator@$AD_DC_IP's password:" { send "Secret123\r" }
}
expect "*#"
send "powershell -executionpolicy bypass ksetup.exe /AddKDC AD.TEST WIN2012R2.AD.TEST\r\n"
expect "*#"
send "exit\r\n"
interact
expect eof
EOF

#put the code here
