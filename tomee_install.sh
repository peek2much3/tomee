#!/bin/bash

# Installs TomcatEE+ on Ubuntu 16.4 LTS
# Pre-reqs: Java 6 or 7 runtime environment in your PATH.
# Must have sudo rights configured

my_ip=`/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
echo ""
sleep 1
echo -e "\033[32m█████████████████████████████████████████\033[m"
echo -e "\033[32m█ WELCOME TO THE TOMEE+ INSTALLATION... █\033[m"
echo -e "\033[32m█████████████████████████████████████████\033[m"
echo ""
sudo mkdir /opt/tomee
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomee tomee
cd /tmp
wget http://repo.maven.apache.org/maven2/org/apache/tomee/apache-tomee/7.0.2/apache-tomee-7.0.2-plus.tar.gz
sudo tar xzvf apache-tomee-7.0.2-plus.tar.gz -C /opt/tomee --strip-components=1
cd /opt/tomee
sudo chgrp -R tomcat /opt/tomee
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomee webapps/ work/ temp/ logs/
read -d '' TOMEESERVICE <<"EOF"
  [Unit]
        Description=Apache TomEE+ Web Application Container
        After=network.target

        [Service]
        Type=forking

        Environment=JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre
        Environment=CATALINA_PID=/opt/tomee/temp/tomee.pid
        Environment=CATALINA_HOME=/opt/tomee
        Environment=CATALINA_BASE=/opt/tomee
        Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
        Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

        ExecStart=/opt/tomee/bin/startup.sh
        ExecStop=/opt/tomee/bin/shutdown.sh

        User=tomee
        Group=tomcat
        UMask=0007
        RestartSec=10
        Restart=always

        [Install]
        WantedBy=multi-user.target
EOF
printf '%s\n' "$TOMEESERVICE" > /etc/systemd/system/tomee.service
sudo systemctl daemon-reload && systemctl enable tomee
sudo systemctl start tomee
echo ""
sleep 1
echo -e "\033[32m███████████████████████████████████████████████████████████████████\033[m"
echo -e "\033[32m█ DONE! Go to http://$my_ip:8080 to verify.                       █\033[m"
echo -e "\033[32m███████████████████████████████████████████████████████████████████\033[m"
echo ""
exit 1
