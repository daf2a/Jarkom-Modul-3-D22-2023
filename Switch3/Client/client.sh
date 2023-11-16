echo 'nameserver 192.168.122.1  # IP NAT' > /etc/resolv.conf

apt-get update

if ! dpkg -l | grep -q dnsutils; then
    apt-get install dnsutils -y
fi

if ! dpkg -l | grep -q lynx; then
    apt-get install lynx -y
fi

if ! dpkg -l | grep -q apache2-utils; then
    apt-get install apache2-utils -y
fi

if ! dpkg -l | grep -q htop; then
    apt-get install htop -y
fi

if ! dpkg -l | grep -q less; then
    apt-get install less -y
fi

if ! dpkg -l | grep -q jq; then
    apt-get install jq -y
fi