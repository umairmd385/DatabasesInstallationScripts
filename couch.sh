#!/bin/bash
echo "This script file will install CouchDB in your linux machine"

read -p "Enter username for your CouchDB database: " user
read -sp "Enter password for your CouchDB database: " pass
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://couchdb.apache.org/repo/couchdb.repo
sudo yum install -y couchdb
sed -i "s/;admin = mysecretpassword/${user} = ${pass}/" /opt/couchdb/etc/local.ini
sed -i 's/;port/port/' /opt/couchdb/etc/local.ini
sed -i 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/' /opt/couchdb/etc/local.ini
systemctl start couchdb
systemctl status couchdb

sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-port=5984/tcp
sudo firewall-cmd --reload