#!/bin/bash
echo "This script file will install cassandra in your linux machine"
echo "In next step, it will prompt to enter the cassandra version.Please use complete version for installation"
echo "For ex., if you need to install cassandra v3.11.10. Then enter '3.11.10'"
read -p "Please enter your version: " ver
sudo yum install java-1.8.0-openjdk-devel curl python3 coreutils -y
cd /opt
curl -OL http://archive.apache.org/dist/cassandra/$ver/apache-cassandra-$ver-bin.tar.gz
tar -xzf apache-cassandra-$ver-bin.tar.gz
rm -rf apache-cassandra-$ver-bin.tar.gz
mv apache-cassandra-$ver cassandra
echo "export PATH=$PATH:/opt/cassandra/bin" >> ~/.bashrc
source ~/.bashrc
cd /opt/cassandra
nohup cassandra -R &

# Enabling cassandra default port from firewall configuration
sudo firewall-cmd --permanent --add-port=9042/tcp
sudo firewall-cmd --reload