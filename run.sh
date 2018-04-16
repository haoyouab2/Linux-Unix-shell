#!/bin/bash

Usage() {
cat <<END
Usage: test.sh [OPTION]...

	-n|--vm_name <VM_NAME>
		Specify the vm guest's name. If not, will generate a random name.

	-p|--path_to_script <path/to/script.ps1>
		Specfiy the path to additional powershell script (suffix .ps1)

	-b|--bridge
		Use only one network interface br0 here instead of two by default so
		the kvm host can communicate directly with kvm guest. But there are
		performance issues.

END
}

[ $# -eq 0 ] && {
	Usage
	exit 1
}

Setup_bridge() {
        DEFAULT_IF=`ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}'`
	if [ $DEFAULT_IF != "br0" ]; then
		NETWORK_PATH="/etc/sysconfig/network-scripts"
		echo -e "TYPE=Bridge
			 BOOTPROTO=dhcp
			 DEVICE=br0
			 ONBOOT=yes" > $NETWORK_PATH/ifcfg-br0
		echo "BRIDGE=br0" >> $NETWORK_PATH/ifcfg-$DEFAULT_IF
		systemctl restart network
		systemctl status network
	fi
	export BRIDGE="bridge=br0,model=rtl8139"
}

while [ -n "$1" ]; do
	case "$1" in
	-n|--vm_name) export VM_NAME="$2";shift 2;;
	-p|--path_to_script) export EXTRA_SCRIPT="${2##*/}";shift 2;;
	-b|--bridge) Setup_bridge;shift 1;;	# Not recommended due to performance issue and setup complexity
	*) Usage;exit 1;;
	esac
done

test -x build || chmod a+x build
./build
