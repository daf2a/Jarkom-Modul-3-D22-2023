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

