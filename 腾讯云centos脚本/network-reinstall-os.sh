#!/bin/sh

MAINIP=$(ip route get 1 | awk '{print $7;exit}')
GATEWAYIP=$(ip route | grep default | awk '{print $3}')
SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')

#proto
DEFAULTNET=$(ip route show |grep -o 'default via [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.*' |head -n1 |sed 's/proto.*\|onlink.*//g' |awk '{print $NF}');
PROTO='dhcp'
PROTOStr=$(ip route show | grep  -o 'default via [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.*' | grep proto)
if [ "$PROTOStr" != "" ]; then
	static=$(ip route show | grep  -o 'default via [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.*' | grep 'proto static')
	if [ "$static" != "" ]; then
		PROTO="static"
	fi
elif [ -f /etc/sysconfig/network-scripts/ifcfg-$DEFAULTNET ]; then
	device=$(cat /etc/sysconfig/network-scripts/ifcfg-$DEFAULTNET | grep DEVICE | grep $DEFAULTNET)
	if [ "$device" != "" ]; then
		static=$(cat /etc/sysconfig/network-scripts/ifcfg-$DEFAULTNET | grep BOOTPROTO | grep static)
		if [ "$static" != "" ]; then
			PROTO="static"
		fi
	fi
elif [ -f /etc/network/interfaces ]; then
	static=$(cat /etc/network/interfaces | grep "iface $DEFAULTNET inet static")
	if [ "$static" != "" ]; then
		PROTO="static"
	fi
elif [ -f /etc/netplan/01-netcfg.yaml ]; then
	device=$(cat /etc/netplan/01-netcfg.yaml | grep $DEFAULTNET)
	if [ "$device" != "" ]; then
		static=$(cat /etc/netplan/01-netcfg.yaml | grep "dhcp4: no")
		if [ "$static" == "" ]; then
			PROTO="static"
		fi
	fi
fi

value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"

wget --no-check-certificate -qO network-reinstall.sh 'https://down.vpsaff.net/linux/dd/network-reinstall.sh' && chmod a+x network-reinstall.sh

#Disabled SELinux
if [ -f /etc/selinux/config ]; then
	SELinuxStatus=$(sestatus -v | grep "SELinux status:" | grep enabled)
	[[ "$SELinuxStatus" != "" ]] && setenforce 0
fi

clear
echo "                                                              "
echo "##############################################################"
echo "#                                                            #"
echo "#  network reinstall OS                                      #"
echo "#                                                            #"
echo "#  Last Modified: 2021-09-27                                 #"
echo "#  Linux默认密码：IdcOffer.com                               #"
echo "#  Supported by idcoffer.com                                 #"
echo "#                                                            #"
echo "##############################################################"
echo "                                                              "
echo "IP: $MAINIP"
echo "网关: $GATEWAYIP"
echo "网络掩码: $NETMASK"
echo ""
echo "请选择您需要的镜像包:"
echo "  0) 升级本脚本"
echo "  1) Debian 9（Stretch） 用户名：root 密码：IdcOffer.com"
echo "  2) Debian 10（Buster） 用户名：root 密码：IdcOffer.com"
echo "  3) Debian 11（Bullseye）用户名：root 密码：IdcOffer.com"
echo "  4) CentOS 7 x64 (DD) 用户名：root 密码：Pwd@CentOS"
echo "  5) CentOS 8 x64 (DD) 用户名：root 密码：cxthhhhh.com 推荐512M以上使用"
echo "  6) CentOS 7 用户名：root 密码：IdcOffer.com, 要求2G RAM以上才能使用"
echo "  7) CentOS 8 (EFI 引导) 用户名：root 密码：IdcOffer.com, 要求2G RAM以上才能使用"
echo "  8) Ubuntu 18.04 LTS (Bionic Beaver) 用户名：root 密码：IdcOffer.com"
echo "  9) Ubuntu 20.04 LTS (Focal Fossa) 用户名：root 密码：IdcOffer.com"
echo "  自定义安装请使用：bash network-reinstall.sh -dd '您的直连'"
echo ""
echo -n "请输入编号: "
read N
case $N in
  0) wget --no-check-certificate -qO network-reinstall-os.sh "https://down.vpsaff.net/linux/dd/network-reinstall-os.sh" && chmod +x network-reinstall-os.sh && wget --no-check-certificate -qO network-reinstall.sh 'https://down.vpsaff.net/linux/dd/network-reinstall.sh' && chmod a+x network-reinstall.sh ;;
  1) bash network-reinstall.sh -d 9 -p IdcOffer.com ;;
  2) bash network-reinstall.sh -d 10 -p IdcOffer.com ;;
  3) bash network-reinstall.sh -d 11 -p IdcOffer.com ;;
  4) echo "Password: Pwd@CentOS" ; read -s -n1 -p "Press any key to continue..." ; bash network-reinstall.sh -dd 'https://down.vpsaff.net/linux/dd/images/centos-7-image' ;;
  5) echo "Password: cxthhhhh.com" ; read -s -n1 -p "Press any key to continue..." ; bash network-reinstall.sh -dd "https://odc.cxthhhhh.com/SyStem/CentOS/CentOS_8.X_NetInstallation_Stable_v3.6.vhd.gz" ;;
  6) bash network-reinstall.sh -c 7 -p IdcOffer.com ;;
  7) bash network-reinstall.sh -c 8 -p IdcOffer.com ;;
  8) bash network-reinstall.sh -u 18.04 -p IdcOffer.com ;;
  9) bash network-reinstall.sh -u 20.04 -p IdcOffer.com ;;
  *) echo "Wrong input!" ;;
esac