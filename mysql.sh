#!/bin/bash
echo "This script file will install mysql database inside your `cat /etc/centos-release`"
echo "Available Mysql version to Install in Centos 7"
echo "1. Mysql 5.7"
echo "2. Mysql 8.0.35"
echo "Please choose between these two version"
echo ""
read -p "Use 'latest or Latest' for mysql 8 or 'Old or old' for mysql 5: " ver
sudo yum update -y
sudo yum install wget curl -y
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install epel-release-latest-7.noarch.rpm -y
sudo yum update -y

if [[ "$ver" == "Latest" || "$ver" == "latest" ]]
then
    read -p "Enter mysql-8 version which you want to install e.g(8.0.35): " mver
    sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm -y
    sudo sed -i -e "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/mysql-community.repo
    sudo sed -i -e "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/mysql-community-source.repo
    sudo yum install mysql-community-server-$mver -y 
    sudo systemctl start mysqld
    sudo systemctl enable --now mysqld
    echo "Next line will print password for mysql server. Login with that one time password and after alter root user password"
    echo "for ex., mysql -u root -p"
    echo "mysql -u root -p"
    echo "Enter password:"
    echo "You this command to alter your root user password"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your-new-password';"
    cat /var/log/mysqld.log | grep "A temporary password" | cut -d'@' -f2 | cut -d ':' -f2 | cut -d ' ' -f2
elif [[ "$ver" == "Old" || "$ver" == "old" ]]
then
    wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
    sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm 
    sudo yum install mysql-community-server -y 
    sudo systemctl start mysqld
    sudo systemctl enable --now mysqld
    echo ""
    echo "Below line will display the temporary password for root user"
    grep 'temporary password' /var/log/mysqld.log
    echo "Use the above password for changing root user password"
    echo "Run 'mysql_secure_installation' for further setup of password"
else
    echo ""
    echo "Wrong choice: `echo $ver`. Use latest or old for installation"
fi
#Adding port 3306 in firewall configuration
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload