#!/bin/bash
sudo yum install -y java-1.8.0-amazon-corretto-devel
sudo yum install -y tomcat httpd mod_proxy mod_proxy_http

# Create Apache VirtualHost to proxy to Tomcat
sudo cat << EOF > /etc/httpd/conf.d/tomcat_manager.conf
<VirtualHost *:80>
  ServerAdmin root@localhost
  ServerName app.nextwork.com
  DefaultType text/html
  ProxyRequests off
  ProxyPreserveHost On
  ProxyPass / http://localhost:8080/nextwork-web-project/
  ProxyPassReverse / http://localhost:8080/nextwork-web-project/
</VirtualHost>
EOF
