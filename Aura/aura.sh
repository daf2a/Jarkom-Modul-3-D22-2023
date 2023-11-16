#!/bin/bash

# Install isc-dhcp-relay
apt-get update
if ! dpkg -l | grep -q isc-dhcp-relay; then
    apt-get install isc-dhcp-relay -y
fi

# Setting DHCP to 
echo "
SERVERS=\"192.202.1.1\"
INTERFACES=\"eth1 eth2 eth3 eth4\"
OPTIONS=
" > /etc/default/isc-dhcp-relay

# Setting IP Forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf

# Restarting services
service isc-dhcp-relay restart