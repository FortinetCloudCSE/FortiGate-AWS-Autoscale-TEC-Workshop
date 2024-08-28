#! /bin/bash
echo "Welcome to TGW Attachment Routing Demo" > /var/www/html/demo.txt
sudo apt update
sudo apt -y upgrade
sudo apt -y install sysstat
sudo apt -y install net-tools
sudo apt -y install iperf3
sudo apt -y install apache2
sudo ufw allow 'Apache'
sudo systemctl start apache2
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt -y install mysql-server
sudo apt -y install php8.1 php8.1-mysql php-pear
apt install -y apache2 mariadb-server mariadb-client php php-mysqli php-gd libapache2-mod-php
sudo apt -y install unzip
cd /var/www/html
sudo wget https://github.com/digininja/DVWA/archive/master.zip
sudo unzip https://github.com/digininja/DVWA/archive/master.zip
sudo rm master.zip

