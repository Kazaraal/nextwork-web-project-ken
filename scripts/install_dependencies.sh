#!/bin/bash

######################################################################################################
###################################### JAVA ##########################################################

# Install Java
sudo yum install -y java-1.8.0-amazon-corretto-devel

######################################################################################################
###################################### TOMCAT ########################################################

# Install wget
sudo yum -y install wget

# Create a tomcat user
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download Tomcat
cd /tmp
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.104/bin/apache-tomcat-9.0.104.tar.gz

# Install Tomcat
sudo mkdir -p /opt/tomcat
sudo tar -xzf apache-tomcat-9.0.104.tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat: /opt/tomcat
sudo chmod -R +x /opt/tomcat/bin

# Create systemd service

sudo bash -c 'cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=\"JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto\"
Environment=\"CATALINA_PID=/opt/tomcat/temp/tomcat.pid\"
Environment=\"CATALINA_HOME=/opt/tomcat\"
Environment=\"CATALINA_BASE=/opt/tomcat\"
Environment=\"CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC\"
Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom\"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemctl and enable/start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat

######################################################################################################
###################################### APACHE HTTPD ##################################################

# Install Apache and proxy modules
sudo yum install -y httpd mod_proxy mod_proxy_http

# Configure Apache VirtualHost for proxing to Tomcat
sudo bash -C 'cat > /etc/httpd/conf.d/tomcat_conf <<EOF
<VirtualHost *:80>
  ServerAdmin root@localhost
  ServerName app.nextwork.com
  DefaultType text/html
  ProxyRequests Off
  ProxyPreserveHost On
  ProxyPass / http://localhost:8080/nextwork-web-project/
  ProxyPassReverse / http://localhost:8080/nextwork-web-project/
</VirtualHost>
EOF'

# Enable and start Apache HTTPD service
sudo systemctl enable --now httpd
