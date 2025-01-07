#!/bin/bash

apt-get update
apt-get install -y net-tools nginx sshpass openssl
mkdir /certs
openssl genrsa > /certs/privkey.pem
openssl req -new -x509 -key /certs/privkey.pem -subj "/C=XX/ST=CA/L=Fremont/O=Suse/CN=$SERVER_0.sslip.io"> /certs/fullchain.pem
echo "events {
    worker_connections 8192;
}

http {
        log_format upstream_time '\$remote_addr - \$remote_user [\$time_local] '
                             '"\$request" \$status \$body_bytes_sent '
                             '"\$http_referer" "\$http_user_agent"'
                             'rt=\$request_time uct="\$upstream_connect_time" uht="\$upstream_header_time" urt="\$upstream_response_time"';

    upstream rancher {
        server $SERVER_0:80;
        server $SERVER_1:80;
        server $SERVER_2:80;
    }

    map \$http_upgrade \$connection_upgrade {
        default Upgrade;
        ''      close;
    }

    server {
        listen 443 ssl http2;
        server_name $SERVER_0.sslip.io;
        ssl_certificate /certs/fullchain.pem;
        ssl_certificate_key /certs/privkey.pem;
        access_log /var/log/nginx/nginx-access.log upstream_time;

        location / {
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-Port \$server_port;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_pass http://rancher;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$connection_upgrade;
            # This allows the ability for the execute shell window to remain open for up to 15 minutes. Without this parameter, the default is 1 minute and will automatically close.
            proxy_read_timeout 900s;
            proxy_buffering off;
        }
    }

    server {
        # commented out lines for public/cloud nodes (i.e. for linode)
        listen 80;
        # listen 22;
        listen 179;
        # uncomment below if using non-aws nodes
        listen 6443;
        listen 2379;
        listen 10250;
        listen 9099;
        listen 9443;
        listen 10254;
        listen 6783;
        listen 9796;
        listen 8443;
        listen 4789;
        listen 8472;
        # listen 30000-32767;
        listen 2376;
        listen 2378;

        server_name $SERVER_0.sslip.io;
        return 301 https://\$server_name\$request_uri;
    }
}" > /etc/nginx/nginx.conf

nginx -t
nginx -s reload