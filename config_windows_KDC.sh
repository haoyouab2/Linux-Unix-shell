#!/bin/bash
# This script is used to configure windows server as a KDC(Key Distribution Center).

P=${0##*/}
#=======================================================================================================
Usage() {
cat <<END
Usage: build_windows_KDC
Usage: get_AD_DC_IP <KVM_HOST_IP>
END
}

[ $# -ne 0 -a $# -ne 1 ] && {
	Usage
	exit 1
}

# variables
KVM_HOST_IP=$1		# ip address of the host machine which runs kvm
VM_NAME="win2012r2"	# default vm guest name
AD_DC_IP=		# AD DC(Active Directory Domain Controller ip address)

build_windows_KDC() {
	# run the case /rhds/provision/beaker/windows-vm/ to set a windows AD DC
	yum -y install ada-rhds-provision-beaker-windows-vm.noarch	# install the case
	export VM_NAME
	cd /mnt/tests/rhds/provision/beaker/windows-vm/			# the default path where the case is installed
	make run
	AD_DC_IP=`cat /var/www/html/$VM_NAME.env | sed -n 's/VM_IP=\(.*\)/\1/p'`

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
	send "powershell -executionpolicy bypass ksetup.exe /AddKDC AD.TEST $(tr a-z A-Z <<< $VM_NAME).AD.TEST\r\n"
	expect "*#"
	send "exit\r\n"
	interact
	expect eof
	EOF
}

get_AD_DC_IP() {	# get AD_DC_IP for nfs server/client
	AD_DC_IP=`ssh $KVM_HOST_IP cat /var/www/html/$VM_NAME.env | sed -n 's/VM_EXT_IP=\(.*\)/\1/p'`
	echo $AD_DC_IP
}

case ${P} in
build_windows_KDC)
	${P} "$@"
;;
get_AD_DC_IP)
	${P} "$@"
;;
*)
	Usage
	exit 1
;;
esac
