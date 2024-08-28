#cloud-config
package_update: true
package_upgrade: true
packages:
    - apache2
    - net-tools
    - sysstat
    - iperf3
    - unzip
    - git
runcmd:
    - [ sh, -c, "echo 'Welcome to TGW Attachment Routing Demo' > /var/www/html/demo.txt" ]
    - sudo ufw allow 'Apache'
    - sudo systemctl start apache2
output : { all : '| tee -a /var/log/cloud-init-output.log' }%
