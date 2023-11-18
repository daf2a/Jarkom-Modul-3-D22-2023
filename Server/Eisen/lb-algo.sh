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