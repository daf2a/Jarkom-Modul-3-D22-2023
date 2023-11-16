#install isc-dhcp-server
apt-get update
if ! dpkg -l | grep -q isc-dhcp-server; then
    apt-get install isc-dhcp-server -y
fi

# Setting DNS
echo 'nameserver 192.202.1.2 # IP Heiter' > /etc/resolv.conf 

# Setting DHCP
echo "
INTERFACESv4=\"eth0\"
INTERFACESv6=\"\"
" > /etc/default/isc-dhcp-server

echo "
ddns-update-style none;
option domain-name \"example.org\";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

authoritative;
log-facility local7;

# eth1
subnet 192.202.1.0 netmask 255.255.255.0 {
  option routers 192.202.1.200;
}

# eth2
subnet 192.202.2.0 netmask 255.255.255.0 {
  option routers 192.202.2.200;
}

# eth3
subnet 192.202.3.0 netmask 255.255.255.0 {
    range 192.202.3.16 192.202.3.32;
    range 192.202.3.64 192.202.3.80;
    option routers 192.202.3.200;
    option broadcast-address 192.202.3.255;
    option domain-name-servers 192.202.1.2;
    default-lease-time 180;
    max-lease-time 5760;
}

# eth4
subnet 192.202.4.0 netmask 255.255.255.0 {
    range 192.202.4.12 192.202.4.20;
    range 192.202.4.160 192.202.4.168;
    option routers 192.202.4.200;
    option broadcast-address 192.202.4.255;
    option domain-name-servers 192.202.1.2;
    default-lease-time 720;
    max-lease-time 5760;
}

# Switch 3
host Lawine {
    hardware ethernet 8a:d5:ad:4c:82:4d;
    fixed-address 192.202.3.1;
}

host Linie {
    hardware ethernet 52:d9:63:1f:56:63;
    fixed-address 192.202.3.2;
}

host Lugner {
    hardware ethernet 0a:82:69:30:bd:ed;
    fixed-address 192.202.3.3;
}

# Switch 4
host Frieren {
    hardware ethernet 36:6a:5c:9e:d1:20;
    fixed-address 192.202.4.1;
}

host Flamme {
    hardware ethernet 22:c6:85:28:61:37;
    fixed-address 192.202.4.2;
}

host Fern {
    hardware ethernet 12:84:e8:38:6f:69;
    fixed-address 192.202.4.3;
}
" > /etc/dhcp/dhcpd.conf

#remove old pid
rm /var/run/dhcpd.pid

#restart service
service isc-dhcp-server restart