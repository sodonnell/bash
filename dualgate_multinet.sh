#!/usr/bin/env bash
#
# filename: dualgate_multinet.sh
#
# dual-gateway, multi-subnet routing 
# using (8) VLAN subnets on a single 
# NIC, attached to a dumb switch.
# 
# Usage: ./dualgate_multinet.sh -i eth1 -a 192.168.0.254
#
# Sean O'Donnell <sean@seanodonnell.com>
#
# $Id: dualgate_multinet.sh,v 1.1 2013/02/09 22:07:45 seanodonnell Exp $
#
while getopts "a::i::l::h::" opt; do
        case $opt in
                i)
            VLAN_NIC=$OPTARG;
            echo -e "\nVLAN_NIC set to: $VLAN_NIC";
            ;;
                a)
            VLAN_NIC_IP=$OPTARG;
            echo -e "\nVLAN_NIC_IP set to: $VLAN_NIC_IP";
            ;;
        *)
            echo -e "\nInvalid option: $opt"
            echo -e "\nOptions: -n (NIC Adapter; i.e. eth1); -i (IP Address; i.e 192.168.0.254);\n"
            exit;
            ;;
    esac
done
# this script assumes sequential subnet matrix mapping, 
# and should not include the Class C subnet of the VLAN_NIC_IP
# i.e. 192.168.1.0/24 - 192.168.8.0/24
LOWNET=1
SUBNETS=8

# gateway table name (used by 'ip route list' or 'ip -s route')
GW_TBL=vlan_gw

# create (virtual) class-c subnets based upon the (physical) VLAN NIC IP Address
VLAN_NIC_SUBNET_A=`echo $VLAN_NIC_IP | cut -d '.' -f 1`
VLAN_NIC_SUBNET_B=`echo $VLAN_NIC_IP | cut -d '.' -f 2`
VLAN_NIC_SUBNET_C=`echo $VLAN_NIC_IP | cut -d '.' -f 3`
VLAN_NIC_SUBNET_D=`echo $VLAN_NIC_IP | cut -d '.' -f 4`
VLAN_SUBNET=$VLAN_NIC_SUBNET_A.$VLAN_NIC_SUBNET_B

if [ ! $LOWNET < $VLAN_NIC_SUBNET_C || ! $HIGHNET > $VLAN_NIC_SUBNET_C ]; then
        echo "The Class C Subnet of the VLAN_NIC_IP address conflicts with your LOWNET/HIGHNET settings."
        exit
fi

# initial script execution checks
if ! `cat /proc/sys/net/ipv4/ip_forward`; then
        echo 1 > /proc/sys/net/ipv4/ip_forward
        if [ -e /etc/sysctl.conf ]; then
                sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf 
        fi
fi

if ! `cat /etc/iproute2/rt_tables | grep 200`; then
        echo 200 $GW_TBL >> /etc/iproute2/rt_tables
fi

ifconfig $VLAN_NIC $VLAN_NIC_IP 

OUTFILE=$0.cache

echo "# iptables class-B subnet routing rules for ($SUBNETS) subnets" > ${OUTFILE}
for (( x=$LOWNET; x<=$SUBNETS; x++ )); do
        ifconfig $VLAN_NIC:$x $VLAN_SUBNET.$x.$VLAN_NIC_SUBNET_D
        ip rule add from $VLAN_SUBNET.$x.0/24 table $GW_TBL
        echo "iptables -A FORWARD -s $VLAN_SUBNET.$x.0/24 -d $VLAN_SUBNET.$VLAN_NIC_SUBNET_D -j ACCEPT" >> ${OUTFILE}
        for (( i=$LOWNET; i<=$SUBNETS; i++ )); do
                if [ $i != $x ]; then
                        echo "iptables -A FORWARD -s $VLAN_SUBNET.${x}.0/24 -d $VLAN_SUBNET.${i}.0/24 -j REJECT" >> ${OUTFILE}
                fi
        done
done

ip route add default via $VLAN_NIC_IP dev $VLAN_NIC table $GW_TBL
ip route flush cache

# execute iptables rules to enable routing
chmod +x ${OUTFILE};
./${OUTFILE}

# for redhat/fedora/centos distros
if [ -e /etc/sysconfig/iptables ]; then
        iptables-save > /etc/sysconfig/iptables
fi

