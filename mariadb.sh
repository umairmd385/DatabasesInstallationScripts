#!/bin/bash

# Prompt the user to enter the version of MariaDB to install
read -p "Enter the version of MariaDB to install (e.g. 10.6): " version
read -p "Enter password for mariadb root user: " pass

# Download the MariaDB RPM package
wget "https://downloads.mariadb.com/MariaDB/mariadb_repo_setup" -O mariadb_repo_setup

# Make the script executable
chmod +x mariadb_repo_setup

# Install the MariaDB repository configuration file for the specified version
./mariadb_repo_setup --mariadb-server-version=${version} --skip-maxscale -y

# Install MariaDB using yum
yum install -y MariaDB-server MariaDB-client

read -p "Do you want to modify default ports and bind address for mariadb? (Y/N): " mod

if [[ "$mod" == "y" || "$mod" == "Y" || "$mod" == "yes" || "$mod" == "Yes" ]]
then
    read -p "Enter the desired port for MariaDB (e.g. 3307): " port
    # Prompt the user to enter the desired bind address for MariaDB
    read -p "Enter the desired bind address for MariaDB (e.g. 127.0.0.1): " bind_address
    sed -i '/^\[mariadb\]/a port = '${port}'\nbind-address = '${bind_address} /etc/my.cnf.d/server.cnf
    #Enabling mariadb port inside firewall configuration
    firewall-cmd --permanent --add-port=${port}/tcp
    firewall-cmd --reload
else
    echo "Using default mariadb port: 3306"
    #Enabling mariadb port inside firewall configuration
    firewall-cmd --permanent --add-port=3306/tcp
    firewall-cmd --reload
fi

# Start the MariaDB service and enable it to start automatically on boot
systemctl start mariadb
systemctl enable mariadb



mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
mysql_upgrade -u root -proot
mysql -u root -proot -e "UPDATE mysql.user SET Password = PASSWORD('`echo ${pass}`') WHERE User = 'root'; FLUSH PRIVILEGES;"
# Remove insecure defaults from the MariaDB installation
mysql -u root -p$pass -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p$pass -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p$pass -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
mysql -u root -p$pass -e "FLUSH PRIVILEGES;"

rm -rf mariadb_repo_setup

