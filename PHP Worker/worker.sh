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