#cloud-config
fqdn: ubuntu-${availability_zone}
repo_update: true
repo_upgrade: true
write_files:
apt:
    ondrej-ppa:
        source: ppa:ondrej/php
packages:
    - apache2
    - net-tools
    - sysstat
    - iperf3
    - mysql-server
    - php8.1
    - php8.1-mysql
    - php-pear
    - mariadb-server
    - mariadb-client
    - php-pysqli
    - php-gd
    - libapache2-mod-php
    - unzip
    - git
runcmd:
    - [ sh, -c, "echo 'Welcome to TGW Attachment Routing Demo' > /var/www/html/demo.txt" ]
    - sudo ufw allow 'Apache'
    - sudo systemctl start apache2
    - rm /etc/netplan/50-cloud-init.yaml
    - mv /etc/netplan/my-new-config.yaml /etc/netplan/50-cloud-init.yaml
    - netplan generate
    - netplan apply
    - cd /var/www/html
    - sudo wget https://github.com/digininja/DVWA/archive/master.zip
    - sudo unzip master.zip
    - sudo rm master.zip
output : { all : '| tee -a /var/log/cloud-init-output.log' }%
