#!/bin/bash

echo 'nameserver 192.168.122.1  # IP NAT' > /etc/resolv.conf

apt-get update
if ! dpkg -l | grep -q bind9; then
  apt-get install bind9 -y
fi

# Setting DNS
echo "
zone \"granz.channel.d22.com\" {
    type master;
    file \"/etc/bind/granz/granz.channel.d22.com\";
};

zone \"riegel.canyon.d22.com\" {
    type master;
    file \"/etc/bind/riegel/riegel.canyon.d22.com\";
};
" > /etc/bind/named.conf.local

# Setting options
echo "
options {
        directory \"/var/cache/bind\";

        forwarders {
                192.168.122.1; // IP NAT
        };

        //dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" > /etc/bind/named.conf.options

# Setting granz
mkdir -p /etc/bind/granz
echo "
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     granz.channel.d22.com. root.granz.channel.d22.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@                 IN      NS      granz.channel.d22.com.
@                 IN      A       192.202.2.2 ; IP Eisen
www               IN      CNAME   granz.channel.d22.com.
" > /etc/bind/granz/granz.channel.d22.com

# Setting riegel
mkdir -p /etc/bind/riegel
echo "
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     riegel.canyon.d22.com. root.riegel.canyon.d22.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@           IN      NS      riegel.canyon.d22.com.
@           IN      A       192.202.2.2 ; IP Eisen
www         IN      CNAME   riegel.canyon.d22.com.
" > /etc/bind/riegel/riegel.canyon.d22.com

# Start services
service bind9 restart