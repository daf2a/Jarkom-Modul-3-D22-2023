# Jarkom-Modul-3-D22-2023

## Anggota

| NRP        | Name                          |
| ---------- | ----------------------------- |
| 5025211016 | Thomas Juan Mahardika Suryono |
| 5025211015 | Muhammad Daffa Ashdaqfillah   |

## Daftar Isi

- [Setup](#setup)
  - [DNS Configruation](#dns-configuration-heiter) (Heiter)
  - [DHCP Server](#dhcp-server-himmel) (Himmel)
  - [DHCP Relay](#dhcp-relay-aura) (Aura)
  - [Database Server](#database-server-denken) (Denken)
  - [Load Balancer](#load-balancer-eisen) (Eisen)
  - [Client](#client-stark-sein-revolte-richter) (Stark, Sein, Revolte, Richter)
  - [Worker PHP](#worker-php-lawine-linie-lugner) (Lawine, Linie, Lugner)
  - [Worker Laravel](#worker-laravel-frieren-flamme-fren) (Frieren, Flamme, Fren)
- [Penyelesaian](#penyelesaian)
  - [Permasalahan](#permasalahan)
  - [Soal 1-5](#soal-1)
  - [Soal 6-12](#soal-6)
  - [Soal 13-20](#soal-13)
- [Grimoire Summary](#grimoire-summary)
  - [Permasalahan Grimoire](#permasalahan-grimoire)
  - [Hasil Grimoire](#hasil-grimoire)
- [Kendala Pengerjaan](#kendala-pengerjaan)


## Setup

### Topologi Map:

![Untitled](Resource/img/Untitled.png)

### Aura (Router)

```bash
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
	address 192.202.1.200
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 192.202.2.200
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 192.202.3.200
	netmask 255.255.255.0

auto eth4
iface eth4 inet static
	address 192.202.4.200
	netmask 255.255.255.0
```

### Himmel (DHCP Server)

```bash
auto eth0
iface eth0 inet static
	address 192.202.1.1
	netmask 255.255.255.0
	gateway 192.202.1.200
```

### Heiter (DNS Server)

```bash
auto eth0
iface eth0 inet static
	address 192.202.1.2
	netmask 255.255.255.0
	gateway 192.202.1.200
```

### Denken (Database Server)

```bash
auto eth0
iface eth0 inet static
	address 192.202.2.1
	netmask 255.255.255.0
	gateway 192.202.2.200
```

### Eisen (Load Balancer)

```bash
auto eth0
iface eth0 inet static
	address 192.202.2.2
	netmask 255.255.255.0
	gateway 192.202.2.200
```

### Lawine (PHP Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 8a:d5:ad:4c:82:4d
```

### Linie (PHP Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 52:d9:63:1f:56:63
```

### Lugner (PHP Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 0a:82:69:30:bd:ed
```

### Frieren (Laravel Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 36:6a:5c:9e:d1:20
```

### Flamme (Laravel Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 22:c6:85:28:61:37
```

### Fren (Laravel Worker)

```bash
auto eth0
iface eth0 inet dhcp
hwaddress ether 12:84:e8:38:6f:69
```

[<< Daftar Isi](#daftar-isi)

## DNS Configuration (Heiter)

```bash
#!/bin/bash

echo 'nameserver 192.168.122.1  # IP NAT' > /etc/resolv.conf

apt-get update
if ! dpkg -l | grep -q bind9; then
  apt-get install bind9 -y
fi

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

service bind9 restart
```

[<< Daftar Isi](#daftar-isi)

## DHCP Server (Himmel)

```bash
apt-get update
if ! dpkg -l | grep -q isc-dhcp-server; then
    apt-get install isc-dhcp-server -y
fi

echo 'nameserver 192.202.1.2 # IP Heiter' > /etc/resolv.conf

echo "
INTERFACESv4=\"eth0\"
INTERFACESv6=\"\"
" > /etc/default/isc-dhcp-server

echo "
ddns-update-style none;
default-lease-time 600;
max-lease-time 7200;

authoritative;
log-facility local7;

subnet 192.202.1.0 netmask 255.255.255.0 {
  option routers 192.202.1.200;
}

subnet 192.202.2.0 netmask 255.255.255.0 {
  option routers 192.202.2.200;
}

subnet 192.202.3.0 netmask 255.255.255.0 {
    range 192.202.3.16 192.202.3.32;
    range 192.202.3.64 192.202.3.80;
    option routers 192.202.3.200;
    option broadcast-address 192.202.3.255;
    option domain-name-servers 192.202.1.2;
    default-lease-time 180;
    max-lease-time 5760;
}

subnet 192.202.4.0 netmask 255.255.255.0 {
    range 192.202.4.12 192.202.4.20;
    range 192.202.4.160 192.202.4.168;
    option routers 192.202.4.200;
    option broadcast-address 192.202.4.255;
    option domain-name-servers 192.202.1.2;
    default-lease-time 720;
    max-lease-time 5760;
}

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

rm /var/run/dhcpd.pid
service isc-dhcp-server restart
```

[<< Daftar Isi](#daftar-isi)

## DHCP Relay (Aura)

```bash
#!/bin/bash

apt-get update
if ! dpkg -l | grep -q isc-dhcp-relay; then
    apt-get install isc-dhcp-relay -y
fi

echo "
SERVERS=\"192.202.1.1\"
INTERFACES=\"eth1 eth2 eth3 eth4\"
OPTIONS=
" > /etc/default/isc-dhcp-relay

echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf

service isc-dhcp-relay restart
```

[<< Daftar Isi](#daftar-isi)

## Database Server (Denken)

```bash
echo 'nameserver 192.168.122.1  # IP NAT' > /etc/resolv.conf
apt-get update
apt-get install mariadb-server -y

echo '

# The MariaDB configuration file
#
# The MariaDB/MySQL tools read configuration files in the following order:
# 1. "/etc/mysql/mariadb.cnf" (this file) to set global defaults,
# 2. "/etc/mysql/conf.d/*.cnf" to set global options.
# 3. "/etc/mysql/mariadb.conf.d/*.cnf" to set MariaDB-only options.
# 4. "~/.my.cnf" to set user-specific options.
#
# If the same option is defined multiple times, the last one will apply.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.

#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

# Import all .cnf files from configuration directory
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
skip-networking=0
skip-bind-address' > /etc/mysql/my.cnf

service mysql restart
```

[<< Daftar Isi](#daftar-isi)

## Load Balancer (Eisen)

```bash
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install nginx -y
apt-get install apache2-utils -y
apt-get install lynx -y

echo '
upstream backend {
 	server 192.202.3.1;
 	server 192.202.3.2;
    server 192.202.3.3;
}

server {
 	listen 80;
 	server_name granz.channel.d22.com;

 	location / {
 	    proxy_pass http://backend;
 	}
    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}

' > /etc/nginx/sites-available/default

ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
service nginx restart
```

[<< Daftar Isi](#daftar-isi)

## Client (Stark, Sein, Revolte, Richter)

```bash
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
```

[<< Daftar Isi](#daftar-isi)

## Worker PHP (Lawine, Linie, Lugner)

```bash
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install ca-certificates wget unzip nginx php php-fpm lynx -y
apt-get install htop -y

wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1' -O granz.channel.yyy.com.zip
unzip granz.channel.yyy.com.zip
mkdir -p /var/www/granz.channel.d22.com
mv modul-3/* /var/www/granz.channel.d22.com
rm granz.channel.yyy.com.zip
rm -rf modul-3

echo "
server {

    listen 80;

    root /var/www/granz.channel.d22.com;

    index index.php index.html index.htm;
    server_name _;

    location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    }

    location ~ /\.ht {
            deny all;
    }

    error_log /var/log/nginx/granz.channel.d22.com_error.log;
    access_log /var/log/nginx/granz.channel.d22.com_access.log;
}
" > /etc/nginx/sites-available/default

ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
service php7.0-fpm start
service nginx restart
```

[<< Daftar Isi](#daftar-isi)

## Worker Laravel (Frieren, Flamme, Fren)

```bash
apt-get update
apt-get install lynx -y
apt-get install mariadb-client -y
apt-get install htop -y

apt -y install lsb-release apt-transport-https ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update

apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y
apt-get install nginx -y
apt-get install wget -y

service nginx start
service php8.0-fpm start

wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/local/bin/composer

apt-get install git -y
cd /var/www && git clone https://github.com/martuafernando/laravel-praktikum-jarkom
cd /var/www/laravel-praktikum-jarkom && composer update

cd /var/www/laravel-praktikum-jarkom && cp .env.example .env
echo 'APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=192.202.2.1
DB_PORT=3306
DB_DATABASE=dbkelompokd22
DB_USERNAME=kelompokd22
DB_PASSWORD=passwordd22

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"' > /var/www/laravel-praktikum-jarkom/.env
cd /var/www/laravel-praktikum-jarkom && php artisan key:generate
cd /var/www/laravel-praktikum-jarkom && php artisan config:cache
cd /var/www/laravel-praktikum-jarkom && php artisan migrate:fresh
cd /var/www/laravel-praktikum-jarkom && php artisan db:seed
cd /var/www/laravel-praktikum-jarkom && php artisan storage:link
cd /var/www/laravel-praktikum-jarkom && php artisan jwt:secret
cd /var/www/laravel-praktikum-jarkom && php artisan config:clear
chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/storage
```

[<< Daftar Isi](#daftar-isi)

## Penyelesaian

### Permasalahan

Setelah mengalahkan Demon King, perjalanan berlanjut. Kali ini, kalian diminta untuk melakukan register domain berupa **riegel.canyon.yyy.com** untuk worker Laravel dan **granz.channel.yyy.com** untuk worker PHP **(0)** mengarah pada worker yang memiliki IP [prefix IP].x.1.

1. **Lakukan konfigurasi sesuai dengan peta yang sudah diberikan.**

Kemudian, karena masih banyak spell yang harus dikumpulkan, bantulah para petualang untuk memenuhi kriteria berikut.:

1. Semua **CLIENT** harus menggunakan konfigurasi dari DHCP Server.
2. Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.16 - [prefix IP].3.32 dan [prefix IP].3.64 - [prefix IP].3.80 **(2)**
3. Client yang melalui Switch4 mendapatkan range IP dari [prefix IP].4.12 - [prefix IP].4.20 dan [prefix IP].4.160 - [prefix IP].4.168 **(3)**
4. Client mendapatkan DNS dari Heiter dan dapat terhubung dengan internet melalui DNS tersebut **(4)**
5. Lama waktu DHCP server meminjamkan alamat IP kepada Client yang melalui Switch3 selama 3 menit sedangkan pada client yang melalui Switch4 selama 12 menit. Dengan waktu maksimal dialokasikan untuk peminjaman alamat IP selama 96 menit **(5)**

Berjalannya waktu, petualang diminta untuk melakukan deployment.

1. Pada masing-masing worker PHP, lakukan konfigurasi virtual host untuk website [berikut](https://drive.google.com/file/d/1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1/view?usp=sharing) dengan menggunakan php 7.3. **(6)**
2. Kepala suku dari [Bredt Region](https://frieren.fandom.com/wiki/Bredt_Region) memberikan resource server sebagai berikut:

   1. Lawine, 4GB, 2vCPU, dan 80 GB SSD.
   2. Linie, 2GB, 2vCPU, dan 50 GB SSD.
   3. Lugner 1GB, 1vCPU, dan 25 GB SSD.

   aturlah agar Eisen dapat bekerja dengan maksimal, lalu lakukan testing dengan 1000 request dan 100 request/second. **(7)**

3. Karena diminta untuk menuliskan grimoire, buatlah analisis hasil testing dengan 200 request dan 10 request/second masing-masing algoritma Load Balancer dengan ketentuan sebagai berikut:
   1. Nama Algoritma Load Balancer
   2. Report hasil testing pada Apache Benchmark
   3. Grafik request per second untuk masing masing algoritma.
   4. Analisis **(8)**
4. Dengan menggunakan algoritma Round Robin, lakukan testing dengan menggunakan 3 worker, 2 worker, dan 1 worker sebanyak 100 request dengan 10 request/second, kemudian tambahkan grafiknya pada grimoire. **(9)**
5. Selanjutnya coba tambahkan konfigurasi autentikasi di LB dengan dengan kombinasi username: “netics” dan password: “ajkyyy”, dengan yyy merupakan kode kelompok. Terakhir simpan file “htpasswd” nya di /etc/nginx/rahasisakita/ **(10)**
6. Lalu buat untuk setiap request yang mengandung /its akan di proxy passing menuju halaman [https://www.its.ac.id](https://www.its.ac.id/). **(11) hint: (proxy_pass)**
7. Selanjutnya LB ini hanya boleh diakses oleh client dengan IP [Prefix IP].3.69, [Prefix IP].3.70, [Prefix IP].4.167, dan [Prefix IP].4.168. **(12)**

Karena para petualang kehabisan uang, mereka kembali bekerja untuk mengatur **granz.channel.yyy.com.**

1. Semua data yang diperlukan, diatur pada Denken dan harus dapat diakses oleh Frieren, Flamme, dan Fern. **(13)**
2. Frieren, Flamme, dan Fern memiliki Granz Channel sesuai dengan [quest guide](https://github.com/martuafernando/laravel-praktikum-jarkom) berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer **(14)**
3. Granz Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.
   1. POST /auth/register **(15)**
   2. POST /auth/login **(16)**
   3. GET /me **(17)**
4. Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur Granz Channel maka implementasikan Proxy Bind pada Eisen untuk mengaitkan IP dari Frieren, Flamme, dan Fern. **(18)**
5. Untuk meningkatkan performa dari Worker, coba implementasikan PHP-FPM pada Frieren, Flamme, dan Fern. Untuk testing kinerja naikkan

   - pm.max_children
   - pm.start_servers
   - pm.min_spare_servers
   - pm.max_spare_servers

   sebanyak tiga percobaan dan lakukan testing sebanyak 100 request dengan 10 request/second kemudian berikan hasil analisisnya pada Grimoire.**(19)**

6. Nampaknya hanya menggunakan PHP-FPM tidak cukup untuk meningkatkan performa dari worker maka implementasikan Least-Conn pada Eisen. Untuk testing kinerja dari worker tersebut dilakukan sebanyak 100 request dengan 10 request/second. **(20)**

[<< Daftar Isi](#daftar-isi)

## Soal 1

> Lakukan konfigurasi sesuai dengan peta yang sudah diberikan.

### Solusi

- Atur konfigurasi setiap node sesuai dengan setup yang telah ada di atas
- Untuk register domain pada `riegel.canyon.d22.com` dan `granz.chanel.d22.com` yang mengarah ke worker dengan ip `192.168.x.`tambakan ini dalam Heiter (DNS Server)
  ```python
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

  echo "
  options {
          directory \"/var/cache/bind\";

          forwarders {
                  192.168.122.1; // IP NAT
          };

          allow-query{any;};

          auth-nxdomain no;
          listen-on-v6 { any; };
  };
  " > /etc/bind/named.conf.options

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
  @                 IN      A       192.202.3.1 ; IP PHP Worker (Lawine)
  www               IN      CNAME   granz.channel.d22.com.
  " > /etc/bind/granz/granz.channel.d22.com

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
  @           IN      A       192.202.4.1 ; IP Laravel Worker (Frieren)
  www         IN      CNAME   riegel.canyon.d22.com.
  " > /etc/bind/riegel/riegel.canyon.d22.com
  ```

### Screenshot Hasil (Client Sein)

![Untitled](Resource/img/Untitled%201.png)

## Soal 2

> 2. Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.16 - [prefix IP].3.32 dan [prefix IP].3.64 - [prefix IP].3.80 **(2)**

### Solusi

- Tambahkan Konfigurasi DHCP pada Himmel (DHCP Server) pada /etc/dhcp/dhcpd.conf
  ```python
  # eth3
  subnet 192.202.3.0 netmask 255.255.255.0 {
      range 192.202.3.16 192.202.3.32;
      range 192.202.3.64 192.202.3.80;
      option routers 192.202.3.200;
  }
  ```

### Screenshot Hasil

- Client Richter (Switch 3)
  ![Untitled](Resource/img/Untitled%203.png)

## Soal 3

> 3. Client yang melalui Switch4 mendapatkan range IP dari [prefix IP].4.12 - [prefix IP].4.20 dan [prefix IP].4.160 - [prefix IP].4.168 **(3)**

### Solusi

- Tambahkan Konfigurasi DHCP pada Himmel (DHCP Server) pada /etc/dhcp/dhcpd.conf
  ```python
  # eth4
  subnet 192.202.4.0 netmask 255.255.255.0 {
      range 192.202.4.12 192.202.4.20;
      range 192.202.4.160 192.202.4.168;
      option routers 192.202.4.200;
  }
  ```

### Screenshot Hasil

- Client Sein (Switch 4)
  ![Untitled](Resource/img/Untitled%204.png)

## Soal 4

> 4. Client mendapatkan DNS dari Heiter dan dapat terhubung dengan internet melalui DNS tersebut **(4)**

### Solusi

- Tambahkan Konfigurasi DHCP untuk `option broadcast-address` dan `option domain-name-servers` pada /etc/dhcp/dhcpd.conf
  ```python
  # eth3
  subnet 192.202.3.0 netmask 255.255.255.0 {
      range 192.202.3.16 192.202.3.32;
      range 192.202.3.64 192.202.3.80;
      option routers 192.202.3.200;
      option broadcast-address 192.202.3.255;
      option domain-name-servers 192.202.1.2;
  }

  # eth4
  subnet 192.202.4.0 netmask 255.255.255.0 {
      range 192.202.4.12 192.202.4.20;
      range 192.202.4.160 192.202.4.168;
      option routers 192.202.4.200;
      option broadcast-address 192.202.4.255;
      option domain-name-servers 192.202.1.2;
  }
  ```
- Restart isc-dhcp-server
  ```python
  service isc-dhcp-server restart
  ```
- Jalankan Setup konfigurasi DHCP Relay (Aura)

### Screenshot Hasil

- Dari Client Sein
  ![Untitled](Resource/img/Untitled%202.png)

## Soal 5

> 5. Lama waktu DHCP server meminjamkan alamat IP kepada Client yang melalui Switch3 selama 3 menit sedangkan pada client yang melalui Switch4 selama 12 menit. Dengan waktu maksimal dialokasikan untuk peminjaman alamat IP selama 96 menit **(5)**

### Solusi

- Di DHCP Server, Tambahkan `default-lease-time` dan `max-lease-team` pada /etc/dhcp/dhcpd.conf
  ```python
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
  ```

### Screenshot Hasil

- Client Richter (Switch 3)
  ![Untitled](Resource/img/Untitled%203.png)
- Client Sein (Switch 4)
  ![Untitled](Resource/img/Untitled%204.png)

[<< Daftar Isi](#daftar-isi)

## Soal 6

> Pada masing-masing worker PHP, lakukan konfigurasi virtual host untuk website [berikut](https://drive.google.com/file/d/1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1/view?usp=sharing) dengan menggunakan php 7.3. **(6)**

### Solusi

- Lakukan apt install dengan modul yang dibutuhkan
  ```python
  apt-get update
  apt-get install ca-certificates wget unzip nginx php php-fpm lynx -y
  ```
- Download file → unzip → pindahkan folder ke /var/www/
  ```python
  wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1' -O granz.channel.yyy.com.zip
  unzip granz.channel.yyy.com.zip
  mkdir -p /var/www/granz.channel.d22.com
  mv modul-3/* /var/www/granz.channel.d22.com
  rm granz.channel.yyy.com.zip
  rm -rf modul-3
  ```
- Tambahkan konfigurasi pada /etc/nginx/sites-available/default
  ```python
  echo "
  server {

      listen 80;

      root /var/www/granz.channel.d22.com;

      index index.php index.html index.htm;
      server_name _;

      location / {
              try_files \$uri \$uri/ /index.php?\$query_string;
      }

      location ~ \.php\$ {
              include snippets/fastcgi-php.conf;
              fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
      }

      location ~ /\.ht {
              deny all;
      }

      error_log /var/log/nginx/granz.channel.d22.com_error.log;
      access_log /var/log/nginx/granz.channel.d22.com_access.log;
  }
  " > /etc/nginx/sites-available/default
  ```
- Start service php7.0-fpm dan nginx
  ```python
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
  service php7.0-fpm start
  service nginx restart
  ```

### Screenshot Hasil

- Pada masing masing Worker, berikan perintah `lynx localhost`
  ![Untitled](Resource/img/Untitled%205.png)

## Soal 7

> Kepala suku dari [Bredt Region](https://frieren.fandom.com/wiki/Bredt_Region) memberikan resource server sebagai berikut: 1. Lawine, 4GB, 2vCPU, dan 80 GB SSD.2. Linie, 2GB, 2vCPU, dan 50 GB SSD. 3. Lugner 1GB, 1vCPU, dan 25 GB SSD. aturlah agar Eisen dapat bekerja dengan maksimal, lalu lakukan testing dengan 1000 request dan 100 request/second. (7)

### Solusi

- Pada Heiter (DNS Server), modifikasi untuk arahkan `granz.channel.d22.com` dan `riegel.canyon.d22.com` ke LB Eisen
  ```python
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

  service bind9 restart
  ```
- Pada Eisen, berikan konfigurasi LB dengan nginx sebagai berikut dengan manipulasi sesuai dengan spesifikasi pada soal yaitu lawine 4GB 2vCPU diberikan weight 8, linie 2GB 2vCPU diberikan weight 4, dan lugner 1GB 1vCPU diberikan weight 1
  ```python
  echo 'nameserver 192.168.122.1' > /etc/resolv.conf

  apt-get update
  apt-get install nginx -y

  echo '
  upstream backend {
   	server 192.202.3.1 weight=8;
   	server 192.202.3.2 weight=4;
    server 192.202.3.3 weight=1;
  }

  server {
   	listen 80;
   	server_name granz.channel.d22.com;

   	location / {
   	    proxy_pass http://backend;
   	}
      error_log /var/log/nginx/lb_error.log;
      access_log /var/log/nginx/lb_access.log;
  }

  ' > /etc/nginx/sites-available/default

  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
  service nginx restart
  ```
- Pada Client, install modul untuk melakukan testing Apache Benchmark
  ```python
  if ! dpkg -l | grep -q apache2-utils; then
      apt-get install apache2-utils -y
  fi
  ```
- Lakukan testing pada client dengan perintah berikut
  ```python
  ab -n 1000 -c 100 http://www.granz.channel.d22.com/
  ```

### Screenshot Hasil

- Load Balancing pada Client (Richter - Revolte - Sein)
  ![Untitled](Resource/img/Untitled%206.png)
- Hasil Testing pada Richter (Client)
  ![Untitled](Resource/img/Untitled%207.png)
  ![Untitled](Resource/img/Untitled%208.png)
  ![Untitled](Resource/img/Untitled%209.png)

## Soal 8

> Karena diminta untuk menuliskan grimoire, buatlah analisis hasil testing dengan 200 request dan 10 request/second masing-masing algoritma Load Balancer dengan ketentuan sebagai berikut:

1. Nama Algoritma Load Balancer
2. Report hasil testing pada Apache Benchmark
3. Grafik request per second untuk masing masing algoritma.
4. Analisis **(8)**

### Solusi

- Lakukan Konfigurasi untuk masing masing algoritma Load Balancer pada Esien
  - **Round Robin**
    ```python
    upstream backend {
     	server 192.202.3.1;
     	server 192.202.3.2;
      server 192.202.3.3;
    }
    ```
  - **Least-connection**
    ```python
    upstream backend {
    	least_conn;
     	server 192.202.3.1;
     	server 192.202.3.2;
      server 192.202.3.3;
    }
    ```
  - **IP Hash**
    ```python
    upstream backend {
    	ip_hash;
     	server 192.202.3.1;
     	server 192.202.3.2;
      server 192.202.3.3;
    }
    ```
  - **Generic Hash**
    ```python
    upstream backend {
    	hash $request_uri consistent;
     	server 192.202.3.1;
     	server 192.202.3.2;
      server 192.202.3.3;
    }
    ```
- Lakukan Testing pada Client dengan perintah berikut
  ```python
  ab -n 200 -c 10 http://www.granz.channel.d22.com/
  ```

### Screenshot Hasil

- **Round Robin**
  ![Untitled](Resource/img/Untitled%2010.png)
  ![Untitled](Resource/img/Untitled%2011.png)
- **Least-connection**
  ![Untitled](Resource/img/Untitled%2012.png)
  ![Untitled](Resource/img/Untitled%2013.png)
- **IP Hash**
  ![Untitled](Resource/img/Untitled%2014.png)
  ![Untitled](Resource/img/Untitled%2015.png)
- **Generic Hash**
  ![Untitled](Resource/img/Untitled%2016.png)
  ![Untitled](Resource/img/Untitled%2017.png)

## Soal 9

> Dengan menggunakan algoritma Round Robin, lakukan testing dengan menggunakan 3 worker, 2 worker, dan 1 worker sebanyak 100 request dengan 10 request/second, kemudian tambahkan grafiknya pada grimoire. **(9)**

### Solusi

- Lakukan Konfigurasi untuk masing masing algoritma Load Balancer pada Esien
  - **Round Robin 1**
    ```python
    upstream backend {
     	server 192.202.3.1;
    }
    ```
  - **Round Robin 2**
    ```python
    upstream backend {
     	server 192.202.3.1;
     	server 192.202.3.2;
    }
    ```
  - **Round Robin 3**
    ```python
    upstream backend {
     	server 192.202.3.1;
     	server 192.202.3.2;
      server 192.202.3.3;
    }
    ```
- Lakukan Testing pada Client dengan perintah berikut
  ```python
  ab -n 100 -c 10 http://www.granz.channel.d22.com/
  ```

### Screenshot Hasil

- **Round Robin 1**
  ![Untitled](Resource/img/Untitled%2018.png)
  ![Untitled](Resource/img/Untitled%2019.png)
- **Round Robin 2**
  ![Untitled](Resource/img/Untitled%2020.png)
  ![Untitled](Resource/img/Untitled%2021.png)
- **Round Robin 3**
  ![Untitled](Resource/img/Untitled%2022.png)
  ![Untitled](Resource/img/Untitled%2023.png)

## Soal 10

> Selanjutnya coba tambahkan konfigurasi autentikasi di LB dengan dengan kombinasi username: “netics” dan password: “ajkyyy”, dengan yyy merupakan kode kelompok. Terakhir simpan file “htpasswd” nya di /etc/nginx/rahasisakita/ **(10)**

### Solusi

- Buat folder dan masukkan Autentikasi
  ```python
  mkdir /etc/nginx/rahasisakita
  htpasswd -c -b /etc/nginx/rahasisakita/htpasswd netics ajkd22
  ```
- Tambahkan Konfigurasi pada /etc/nginx/sites-available/default
  ```python
  location / {
   	    proxy_pass http://backend;
        auth_basic \"Autitenikasi\";
        auth_basic_user_file /etc/nginx/rahasisakita/htpasswd;
  }
  ```

### Screenshot Hasil

- Saat mengakses granz.chanel.d22.com
  ![Untitled](Resource/img/Untitled%2024.png)
  ![Untitled](Resource/img/Untitled%2025.png)
  ![Untitled](Resource/img/Untitled%2026.png)
  ![Untitled](Resource/img/Untitled%2027.png)

## Soal 11

> Lalu buat untuk setiap request yang mengandung /its akan di proxy passing menuju halaman [https://www.its.ac.id](https://www.its.ac.id/). **(11) hint: (proxy_pass)**

### Solusi

- Tambahkan Konfigurasi location ~ /its pada /etc/nginx/sites-available/default
  ```python
  location ~ /its {
      proxy_pass https://www.its.ac.id;
  }
  ```
- Untuk pengetesan dapat menggunakan /its pada lynx
  ```python
  lynx www.granz.channel.d22.com/its
  ```

### Screenshot Hasil

- Pada Richter (Client)
  ![Untitled](Resource/img/Untitled%2028.png)

## Soal 12

> Selanjutnya LB ini hanya boleh diakses oleh client dengan IP [Prefix IP].3.69, [Prefix IP].3.70, [Prefix IP].4.167, dan [Prefix IP].4.168. **(12)**

### Solusi

- Tambahkan Konfigurasi /location untuk memfix ip client pada /etc/nginx/sites-available/default
  ```python
  location / {
          allow 192.202.3.69;
          allow 192.202.3.70;
          allow 192.202.4.167;
          allow 192.202.4.168;
          deny all;
  	 	    proxy_pass http://backend;
          auth_basic \"Autitentikasi\";
          auth_basic_user_file /etc/nginx/rahasisakita/htpasswd;
   	}
  ```

- Tambahkan konfigurasi untuk Fix IP client pada DHCP Server (Himmel)
  ```python
  host Revolte {
      hardware ethernet 0b:14:21:14:bd:e0;
      fixed-address 192.202.3.69;
  }

  host Richter {
      hardware ethernet 38:6b:5d:9a:d1:43;
      fixed-address 192.202.3.70;
  }

  host Sein {
      hardware ethernet 12:d6:25:38:11:27;
      fixed-address 192.202.4.167;
  }

  host Stark {
      hardware ethernet 32:34:a8:48:6d:10;
      fixed-address 192.202.4.168;
  }
  ```

- Lalu lakukan konfigurasi juga terhadap masing masing client seperti ini 
```python
  auto eth0
  iface eth0 inet dhcp
  hwaddress ether [sesuaikan dengan konfigurasi di atas]
```

### Screenshot Hasil

- Pada Richter dengan IP acak 192.202.3.24; `Tidak bisa Akses`
  ![Untitled](Resource/img/Untitled%2029.png)
  ![Untitled](Resource/img/Untitled%2030.png)
- Untuk membuktikan Pemberian akses, IP dari Client di Fix kan agar sesuai dengan hak akses pada LB. Lalu dilakukan pengujian ulang `berhasil`
  ![Untitled](Resource/img/Untitled%2031.png)

[<< Daftar Isi](#daftar-isi)

## Soal 13

> Semua data yang diperlukan, diatur pada Denken dan harus dapat diakses oleh Frieren, Flamme, dan Fern. **(13)**

### Solusi

- Jalankan Setup Konfigurasi pada Denken (Database Server ) dan Worker Laravel
- Masuk ke mariadb `mysql -u root -p` dan jalankan query berikut
  ```python
  CREATE USER 'kelompokd22'@'%' IDENTIFIED BY 'passwordd22';
  CREATE USER 'kelompokd22'@'localhost' IDENTIFIED BY 'passwordd22';
  CREATE DATABASE dbkelompokd22;
  GRANT ALL PRIVILEGES ON *.* TO 'kelompokd22'@'%';
  GRANT ALL PRIVILEGES ON *.* TO 'kelompokd22'@'localhost';
  FLUSH PRIVILEGES;
  ```
- Restart mysql `service mysql restart`
- Pada Worker yang sudah disetup mariadb-client, lakukan testing untuk mengakses database
  ```python
  mysql --host=192.202.2.1 --port=3306 --user=kelompokd22 --password=passwordd22
  ```

### Screenshot Hasil

- Query SQL
  ![Untitled](Resource/img/Untitled%2032.png)
- Testing akses databases dari Worker
  ![Untitled](Resource/img/Untitled%2033.png)

## Soal 14

> Frieren, Flamme, dan Fern memiliki Granz Channel sesuai dengan [quest guide](https://github.com/martuafernando/laravel-praktikum-jarkom) berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer **(14)**

### Solusi

- Lakukan setup pada masing masing worker terlebih dahulu untuk menginstall php8 composer serta file Laravel-github
- Pada `php artisan migrate` terdapat eror yang dapat diselesaikan dengan menambahkan kode ini pada /app/Providers/AppServiceProvider.php
  ```python
  use Illuminate\Support\Facades\Schema;

  /**
   * Bootstrap any application services.
   *
   * @return void
   */
  public function boot()
  {
      Schema::defaultStringLength(191);
  }
  ```
- Setelah berhasil konfigurasi laravel, pada masing masing worker, lakukan setting untuk nginx sesuai dengan port yang telah ditentukan masing masing worker
  ```python
  echo 'server {
      listen 8001; # Frieren
      listen 8002; # Flamme
      listen 8003; # Fren

      root /var/www/laravel-praktikum-jarkom/public;

      index index.php index.html index.htm;
      server_name _;

      location / {
              try_files $uri $uri/ /index.php?$query_string;
      }

      location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
      }

      location ~ /\.ht {
              deny all;
      }

      error_log /var/log/nginx/error.log;
      access_log /var/log/nginx/access.log;
  }' > /etc/nginx/sites-available/default

  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
  service php8.0-fpm start
  service nginx restart
  ```
- Restart Nginx dan php8.0-fpm

### Screenshot Hasil

- Jalankan `lynx localhost:[port]` pada setiap worker
  ![Untitled](Resource/img/Untitled%2034.png)

## Soal 15

> Granz Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.

1. POST /auth/register **(15)**
   >

### Solusi

- Buat file json untuk data yang akan di post
  ```python
  echo '
  {
    "username": "kelompokd22",
    "password": "passwordd22"
  }' > register.json
  ```
- Lakukan pengujian apache benchmark pada salah satu clietn (Sein) dengan perintah
  ```python
  ab -n 100 -c 10 -p register.json -T application/json http://192.202.4.1:8001/api/auth/register
  ```
- Untuk mendapatkan response, lakukan curl seperti berikut
  ```python
  curl -X POST -H "Content-Type: application/json" -d @register.json http://192.202.4.1:8001/api/auth/register -o register_response.txt
  ```

### Screenshot Hasil

- Pengujian apache benchmark dari Sein (Client) ke Frieren (Worker Laravel)
  ![Untitled](Resource/img/Untitled%2035.png)
- Response
  ![Untitled](Resource/img/Untitled%2052.png)

## Soal 16

> Granz Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire. 2. POST /auth/login **(16)**

### Solusi

- Buat file json untuk data yang akan di post
  ```python
  echo '
  {
    "username": "kelompokd22",
    "password": "passwordd22"
  }' > register.json
  ```
- Lakukan pengujian apache benchmark pada salah satu clietn (Sein) dengan perintah
  ```python
  ab -n 100 -c 10 -p register.json -T application/json http://192.202.4.1:8001/api/auth/login
  ```
- Untuk mendapatkan response, lakukan curl seperti berikut
  ```python
  curl -X POST -H "Content-Type: application/json" -d @register.json http://192.202.4.1:8001/api/auth/login > login_response.txt
  ```

### Screenshot Hasil

- Pengujian apache benchmark dari Sein (Client) ke Frieren (Worker Laravel)
  ![Untitled](Resource/img/Untitled%2036.png)
- Hasil Akhir
  ![Untitled](Resource/img/Untitled%2037.png)
- Response
  ![Untitled](Resource/img/Untitled%2053.png)

## Soal 17

> Granz Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire. 3. GET /me **(17)**

### Solusi

- Pada endpoint Get /me diperlukan Request Header berupa Bearer Token, oleh karena itu sebelum mengakses perlu didapatkan tokennya terlebih dahulu
  ```python
  curl -X POST -H "Content-Type: application/json" -d @register.json http://192.202.4.1:8001/api/auth/login > login_response.txt
  ```
- Setelah mendapatkan token, set token sebagai global
  ```python
  token=$(cat login_response.txt | jq -r '.token')
  ```
- Jalankan Testing
  ```python
  ab -n 100 -c 10 -H "Authorization: Bearer $token" http://192.202.4.1:8001/api/me
  ```
- Untuk mendapatkan response, lakukan curl seperti berikut
  ```python
  curl -X GET -H "Authorization: Bearer $token" http://192.202.4.1:8001/api/me > get_response.txt
  ```

### Screenshot Hasil

- Pengujian apache benchmark dari Sein (Client) ke Frieren (Worker Laravel)
  ![Untitled](Resource/img/Untitled%2038.png)
- Response
  ![Untitled](Resource/img/Untitled%2054.png)

## Soal 18

> Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur Granz Channel maka implementasikan Proxy Bind pada Eisen untuk mengaitkan IP dari Frieren, Flamme, dan Fern. **(18)**

### Solusi

- Untuk mengimplementasikan Load Balancer pada Laravel Worker, buat konfigurasi baru untuk worker laravel pada LB (Eisen)
  ```python
  	echo 'upstream backend {
  	    server 192.202.4.1:8001; # IP Frieren
  	    server 192.202.4.2:8002; # IP Flamme
  	    server 192.202.4.3:8003; # IP Fern
  	}

  	server {
  	    listen 80;
  	    server_name riegel.canyon.d22.com;

  	    location / {
  	        proxy_pass http://backend;
  	    }
  	    error_log /var/log/nginx/lb_laravel_error.log;
  	    access_log /var/log/nginx/lb_laravel_access.log;
  	}
  	' > /etc/nginx/sites-available/default

  	ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
  	service nginx restart
  ```
- Setelah itu restart nginx dan jalankan test ulang dari client dengan
  ```python
  ab -n 100 -c 10 -H "Authorization: Bearer $token" http://riegel.canyon.d22.com/api/me
  ```

### Screenshot Hasil

- Pengujian apache benchmark dari Sein (Client) pada 3 Worker Laravel
  ![Untitled](Resource/img/Untitled%2039.png)
  ![Untitled](Resource/img/Untitled%2040.png)
- Log Access
  ![Untitled](Resource/img/Untitled%2041.png)

## Soal 19

> Untuk meningkatkan performa dari Worker, coba implementasikan PHP-FPM pada Frieren, Flamme, dan Fern. Untuk testing kinerja naikkan pm.max_children, pm.start_servers, pm.min_spare_servers, pm.max_spare_servers. Sebanyak tiga percobaan dan lakukan testing sebanyak 100 request dengan 10 request/second kemudian berikan hasil analisisnya pada Grimoire.(19)

### Solusi

- Percobaan 1
  ```python
  echo '[laravel]
  user = laravel
  group = laravel
  listen = /var/run/php8.1-fpm-dressrosa-site.sock
  listen.owner = www-data
  listen.group = www-data
  php_admin_value[disable_functions] = exec,passthru,shell_exec,system
  php_admin_flag[allow_url_fopen] = off

  ; Choose how the process manager will control the number of child processes.

  pm = dynamic
  pm.max_children = 50
  pm.start_servers = 10
  pm.min_spare_servers = 2
  pm.max_spare_servers = 15
  pm.process_idle_timeout = 10s

  ;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
  ' > /etc/php/8.0/fpm/pool.d/www.conf

  service php8.0-fpm restart
  service nginx restart
  ```
- Percobaan 2
  ```python
  echo '[laravel]
  user = laravel
  group = laravel
  listen = /var/run/php8.1-fpm-dressrosa-site.sock
  listen.owner = www-data
  listen.group = www-data
  php_admin_value[disable_functions] = exec,passthru,shell_exec,system
  php_admin_flag[allow_url_fopen] = off

  ; Choose how the process manager will control the number of child processes.

  pm = dynamic
  pm.max_children = 75
  pm.start_servers = 15
  pm.min_spare_servers = 5
  pm.max_spare_servers = 25
  pm.process_idle_timeout = 10s

  ;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
  ' > /etc/php/8.0/fpm/pool.d/www.conf

  service php8.0-fpm restart
  service nginx restart
  ```
- Percobaan 3
  ```python
  echo '[laravel]
  user = laravel
  group = laravel
  listen = /var/run/php8.1-fpm-dressrosa-site.sock
  listen.owner = www-data
  listen.group = www-data
  php_admin_value[disable_functions] = exec,passthru,shell_exec,system
  php_admin_flag[allow_url_fopen] = off

  ; Choose how the process manager will control the number of child processes.

  pm = dynamic
  pm.max_children = 100
  pm.start_servers = 20
  pm.min_spare_servers = 10
  pm.max_spare_servers = 30
  pm.process_idle_timeout = 10s

  ;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
  ' > /etc/php/8.0/fpm/pool.d/www.conf

  service php8.0-fpm restart
  service nginx restart
  ```

### Screenshot Hasil

- Percobaan 1 menggunakan endpoint Get /me sebanyak 100 request dengan 10 request/second.
  ![Untitled](Resource/img/Untitled%2042.png)
  ![Untitled](Resource/img/Untitled%2043.png)
- Percobaan 2 menggunakan endpoint Get /me sebanyak 100 request dengan 10 request/second.
  ![Untitled](Resource/img/Untitled%2044.png)
  ![Untitled](Resource/img/Untitled%2045.png)
- Percobaan 3 menggunakan endpoint Get /me sebanyak 100 request dengan 10 request/second.
  ![Untitled](Resource/img/Untitled%2046.png)
  ![Untitled](Resource/img/Untitled%2047.png)

## Soal 20

> Nampaknya hanya menggunakan PHP-FPM tidak cukup untuk meningkatkan performa dari worker maka implementasikan Least-Conn pada Eisen. Untuk testing kinerja dari worker tersebut dilakukan sebanyak 100 request dengan 10 request/second. **(20)**

### Solusi

- Lakukan pengeditan pada LB Eisen untuk menambahkan `least_conn` dalam upstream
  ```python
  echo 'upstream backend {
  			least_conn;
  	    server 192.202.4.1:8001; # IP Frieren
  	    server 192.202.4.2:8002; # IP Flamme
  	    server 192.202.4.3:8003; # IP Fern
  	}

  	server {
  	    listen 80;
  	    server_name riegel.canyon.d22.com;

  	    location / {
  	        proxy_pass http://backend;
  	    }
  	    error_log /var/log/nginx/lb_laravel_error.log;
  	    access_log /var/log/nginx/lb_laravel_access.log;
  	}
  	' > /etc/nginx/sites-available/default

  	ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
  	service nginx restart
  ```

### Screenshot Hasil

- Pengujian menggunakan endpoint Get /me sebanyak 100 request dengan 10 request/second.
  ![Untitled](Resource/img/Untitled%2048.png)
  ![Untitled](Resource/img/Untitled%2049.png)

[<< Daftar Isi](#daftar-isi)


## Grimoire Summary

### Permasalahan Grimoire

1. Karena diminta untuk menuliskan grimoire, buatlah analisis hasil testing dengan 200 request dan 10 request/second masing-masing algoritma Load Balancer dengan ketentuan sebagai berikut:
    1. Nama Algoritma Load Balancer
    2. Report hasil testing pada Apache Benchmark
    3. Grafik request per second untuk masing masing algoritma.
    4. Analisis **(8)**
2. Dengan menggunakan algoritma Round Robin, lakukan testing dengan menggunakan 3 worker, 2 worker, dan 1 worker sebanyak 100 request dengan 10 request/second, kemudian tambahkan grafiknya pada grimoire. **(9)**
3. Riegel Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.
    1. POST /auth/register **(15)**
    2. POST /auth/login **(16)**
    3. GET /me **(17)**
4. Untuk meningkatkan performa dari Worker, coba implementasikan PHP-FPM pada Frieren, Flamme, dan Fern. Untuk testing kinerja naikkan
    - pm.max_children
    - pm.start_servers
    - pm.min_spare_servers
    - pm.max_spare_servers
    
    sebanyak tiga percobaan dan lakukan testing sebanyak 100 request dengan 10 request/second kemudian berikan hasil analisisnya pada Grimoire. **(19)**
    

## Hasil Grimoire

### Soal 8

**Hasil Testing :**

1. **Round Robin**
    
    ![Untitled](Resource/img/Untitled%2010.png)
    
    ![Untitled](Resource/img/Untitled%2011.png)
    
2. **Least-connection** 
    
    ![Untitled](Resource/img/Untitled%2012.png)
    
    ![Untitled](Resource/img/Untitled%2013.png)
    
3. **IP Hash**
    
    ![Untitled](Resource/img/Untitled%2014.png)
    
    ![Untitled](Resource/img/Untitled%2015.png)
    
4. **Generic Hash**
    
    ![Untitled](Resource/img/Untitled%2016.png)
    
    ![Untitled](Resource/img/Untitled%2017.png)
    

**Tabel :**

| Algoritma | Request per Second |
| --- | --- |
| Round Robin | 696,93 |
| Least Connection | 589,82 |
| IP Hash | 604,35 |
| Generic IP | 642,04 |

**Grafik :**

![Untitled](Resource/img/Untitled%2050.png)

**Annlisis :**

Dari hasil uji load balancing di atas, didapatkan metode dengan hasil yang paling tinggi dalam request per second adalah round robin. Round robin sendrii adalah algoritma load balancing yan gmembagi lalu lintas secara merata dan bergantian, Keuntungan dari metode ini adalah sederhana dan mudah diimplementasikan. Round robin terhitung dapat menangani request paling banyak setiap detiknya, hal ini mungkin dikarenakan metodenya yang tidak terlalu rumit dan tidak membutuhkan komputasi yang tinggi untuk tes sederhana dari apache benchmark.

Sedangkan posisi setelahnya yaitu Generic IP yang mengoptimalkan penyebaran beban kepada worker. Selanjutnya terdapat IP Hash yang memastikan bahwa permintaan dari alamat IP yang sama ditangai oleh server yang sama. dan yang terakhir yaitu least connection, algoritma ini kurang optimal dalam tes ab yang mengarahkan permintaan server ke koneksi terendah pada saat itu (beban terendah) untuk menangani permintaan baru.

### Soal 9

**Hasil Testing :**

1. **Round Robin 1**
    
    ![Untitled](Resource/img/Untitled%2018.png)
    
    ![Untitled](Resource/img/Untitled%2019.png)
    
2. **Round Robin 2**
    
    ![Untitled](Resource/img/Untitled%2020.png)
    
    ![Untitled](Resource/img/Untitled%2021.png)
    
3. **Round Robin 3**
    
    ![Untitled](Resource/img/Untitled%2022.png)
    
    ![Untitled](Resource/img/Untitled%2023.png)
    

**Tabel :**

| Algoritma | Request per Second |
| --- | --- |
| 1 Worker | 615,95 |
| 2 Worker | 570,72 |
| 3 Worker | 553,35 |

**Grafik :**

![Untitled](Resource/img/Untitled%2051.png)

**Annlisis :**

Dalam hasil uji load balancing Round Robin dengan jumalh worker yang berbeda, dapat terlihat bahwa penggunaan 1 worker memberikan kinerja yang lebih tinggi dalam menangani request epr detik dibandingkan dengan  2 worker maupun 3 worker. Hal ini dapat terjadi karena permintaan yang terhitung sedikit dalam tes ab, sehingga 1 worker sudah sangat cukup untuk menangani request tersebut tanpa harus bergantian dengan worker lain yang mungkin memakan lebih waktu untuk penangannanya. Namun jika permintaan ab dimasukkan dalam skala yang besar, dimana 1 worker tidak cukup untuk menangani semua request, penambahan worker dapat menajadi solusi yang optimal.

### Soal 15-17

Response :

1. POST /auth/register
    
    ![Untitled](Resource/img/Untitled%2052.png)
    
2. POST /auth/login 
    
    ![Untitled](Resource/img/Untitled%2053.png)
    
3. GET /me 
    
    ![Untitled](Resource/img/Untitled%2054.png)
    

**Hasil Testing :**

1. POST /auth/register
    
    ![Untitled](Resource/img/Untitled%2035.png)
    
2. POST /auth/login 
    
    ![Untitled](Resource/img/Untitled%2037.png)
    
3. GET /me 
    
    ![Untitled](Resource/img/Untitled%2038.png)
    

### Soal 19

Konfigurasi :

1. Percobaan 1
    
    ```python
    pm = dynamic
    pm.max_children = 50
    pm.start_servers = 10
    pm.min_spare_servers = 2
    pm.max_spare_servers = 15
    pm.process_idle_timeout = 10s
    ```
    
2. Percobaan 2
    
    ```python
    pm = dynamic
    pm.max_children = 75
    pm.start_servers = 15
    pm.min_spare_servers = 5
    pm.max_spare_servers = 25
    pm.process_idle_timeout = 10s
    ```
    
- Percobaan 3
    
    ```python
    pm = dynamic
    pm.max_children = 100
    pm.start_servers = 20
    pm.min_spare_servers = 10
    pm.max_spare_servers = 30
    pm.process_idle_timeout = 10s
    ```
    

**Hasil Testing :**

1. Percobaan 1
    
    ![Untitled](Resource/img/Untitled%2042.png)
    
    ![Untitled](Resource/img/Untitled%2043.png)
    
2. Percobaan 2
    
    ![Untitled](Resource/img/Untitled%2044.png)
    
    ![Untitled](Resource/img/Untitled%2045.png)
    
3. Percobaan 3
    
    ![Untitled](Resource/img/Untitled%2046.png)
    
    ![Untitled](Resource/img/Untitled%2047.png)
    

**Tabel :**

| Percobaan | Request per Second |
| --- | --- |
| 1 | 894,41 |
| 2 | 768,39 |
| 3 | 786,62 |

**Annlisis :**

Dari hasil pengujian penambahan pm.max_children, pm.start_servers, pm.min_spare_servers, pm.max_spare_servers. Seiring dengan adanya penambahan  pada variable di atas, kinerja untuk menerima request semakin menurutn. Hal ini dapat terjadi disebabkan beban yang diterima dalam satu waktu semakin besar dan menyebabkan komputasi mengalami overhead yang menyebabkan perlambatan dalam menerima request. Jika Resource yang dimiliki komputer cukup tinggi, penambahan konfigurasi pada variable tersebut mungkin dapat meningkatkan kinerja permintaan request.

[<< Daftar Isi](#daftar-isi)

## Kendala Pengerjaan

- Sempat salah dalam memilih image docker berupa ubuntu-1 bukan debian sehingga cukup membingungkan karena tidak dapat digunakan untuk menginstall composer

[<< Daftar Isi](#daftar-isi)