#!/bin/sh

IFCONFIG="/sbin/ifconfig"
IP="/sbin/ip"
INTERFACES="/etc/network/interfaces"

IFACE=$($IFCONFIG | grep HWaddr | cut -d " " -f 1)
ADDRESS=$($IFCONFIG | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
NETMASK=$($IFCONFIG | grep -w inet |grep -v 127.0.0.1| awk '{print $4}' | cut -d ":" -f 2)
GATEWAY=$($IP route | awk '/\<default\>/ {print $3; exit}')

cat <<-IPCONFIG > "$INTERFACES"
        auto lo $IFACE

        iface lo inet loopback

        iface $IFACE inet static
                pre-up /sbin/ethtool -K $IFACE tso off
                pre-up /sbin/ethtool -K $IFACE gso off

                address $ADDRESS
                netmask $NETMASK
                gateway $GATEWAY

# Exit and save:	[CTRL+X] + [Y] + [ENTER]
# Exit without saving:	[CTRL+X]

IPCONFIG

exit 0
