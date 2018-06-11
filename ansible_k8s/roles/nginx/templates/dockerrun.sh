docker load -i /etc/nginx/nginx.tar
docker run -d -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf -p {{nginx_port}}:8080 nginx:1.11.5
