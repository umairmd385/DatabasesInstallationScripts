#!/bin/bash
echo "This script file will install mssql in your `cat /etc/centos-release`"
echo ""
echo "Avaiable MsSQL version installation for centos 7"
echo "1. Mssql 2017"
echo "2. Mssql 2019"
echo ""
echo "Please choose between these versions and enter your version from the given chooice"
echo ""
read -p "Please Enter '1' for Mssql 2017 or '2' for Mssql 2019: " ver


if [[ "$ver" == "1" ]]
then
    echo "You choose to install Mssql server 2017"
    sudo yum update -y 
    sudo yum install python2 openssl-devel openssl -y
    echo ""
    echo "You need to switch python version to python2, to complete the installation"
    sudo alternatives --config python
    # Password for the SA user (required)
    read -p "Enter your password for mssql SA user: " password
    MSSQL_SA_PASSWORD=`echo $password`

    # Product ID of the version of SQL Server you're installing
    # Must be evaluation, developer, express, web, standard, enterprise, or your 25 digit product key
    # Defaults to developer
    MSSQL_PID='developer'

    # Enable SQL Server Agent (recommended)
    SQL_ENABLE_AGENT='y'


    if [ -z $MSSQL_SA_PASSWORD ]
    then
    echo Environment variable MSSQL_SA_PASSWORD must be set for unattended install
    exit 1
    fi

    echo Adding Microsoft repositories...
    sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo
    sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

    echo Installing SQL Server...
    sudo yum install -y mssql-server

    echo Running mssql-conf setup...
    sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
        MSSQL_PID=$MSSQL_PID \
        /opt/mssql/bin/mssql-conf -n setup accept-eula

    echo Installing mssql-tools and unixODBC developer...
    sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel

    # Add SQL Server tools to the path by default:
    echo Adding SQL Server tools to your path...
    echo "export PATH=$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
    echo "export PATH=$PATH:/opt/mssql-tools/bin" >> ~/.bashrc
    source ~/.bashrc
    source ~/.bash_profile
elif [[ "$ver" == "2" ]]
then
    echo "You choose to install Mssql server 2019"
    sudo yum update -y 
    sudo yum install python2 openssl-devel openssl -y
    echo ""
    echo "You need to switch python version to python2, to complete the installation"
    sudo alternatives --config python
    # Password for the SA user (required)
    read -p "Enter your password for mssql SA user: " password
    MSSQL_SA_PASSWORD=`echo $password`

    # Product ID of the version of SQL Server you're installing
    # Must be evaluation, developer, express, web, standard, enterprise, or your 25 digit product key
    # Defaults to developer
    MSSQL_PID='developer'

    # Enable SQL Server Agent (recommended)
    SQL_ENABLE_AGENT='y'


    if [ -z $MSSQL_SA_PASSWORD ]
    then
    echo Environment variable MSSQL_SA_PASSWORD must be set for unattended install
    exit 1
    fi

    echo "Adding Microsoft repositories..."
    sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo
    sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

    echo "Installing SQL Server..."
    sudo yum install -y mssql-server

    echo "Running mssql-conf setup..."
    sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
        MSSQL_PID=$MSSQL_PID \
        /opt/mssql/bin/mssql-conf -n setup accept-eula

    echo "Installing mssql-tools and unixODBC developer..."
    sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel

    # Add SQL Server tools to the path by default:
    echo Adding SQL Server tools to your path...
    echo "export PATH=$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
    echo "export PATH=$PATH:/opt/mssql-tools/bin" >> ~/.bashrc
    source ~/.bashrc
    source ~/.bash_profile
else
    echo "Your choice is incorrect."
fi


# Configure firewall to allow TCP port 1433:
echo "Configuring firewall to allow traffic on port 1433..."
sudo firewall-cmd --add-port=1433/tcp --permanent
sudo firewall-cmd --reload


echo "Please run 'source ~/.bashrc' to reload all paths on the same terminal."