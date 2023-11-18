echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install nginx -y
apt-get install apache2-utils -y
apt-get install lynx -y

mkdir /etc/nginx/rahasisakita
htpasswd -c -b /etc/nginx/rahasisakita/htpasswd netics ajkd22

echo "
upstream backend {
 	server 192.202.3.1;
 	server 192.202.3.2;
    server 192.202.3.3;
}

server {
 	listen 80;
 	server_name granz.channel.d22.com;

 	location / {
        allow 192.202.3.69;
        allow 192.202.3.70;
        allow 192.202.3.24;
        allow 192.202.4.167;
        allow 192.202.4.168;
        deny all;
 	    proxy_pass http://backend;
        auth_basic \"Autitentikasi\";
        auth_basic_user_file /etc/nginx/rahasisakita/htpasswd;
 	}

    location ~ /its {
        proxy_pass https://www.its.ac.id;
    }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
" > /etc/nginx/sites-available/default

ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
service nginx restart

