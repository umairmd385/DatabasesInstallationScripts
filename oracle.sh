#!/bin/bash

echo "This script file will install Oracle DB in your linux machine"

#Installing Xorg Remote display tool
yum install -y xorg-x11-xauth xterm

#Modifying sshd config file for allow X11 Forwarding 

sed -i 's/#\?X11Forwarding\s\+no/X11Forwarding yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
#sed -i 's/#\?X11UseLocalhost\s\+yes/X11UseLocalhost yes/' /etc/ssh/sshd_config

#Adding Xwrapper.config file for allowing remote display for anyuser

echo "allowed_users=anybody" > /etc/X11/Xwrapper.config 

#Restarting sshd

sudo systemctl restart sshd

yum -y install wget curl unzip binutils compat-libcap1 smartmontools.x86_64 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel compat-libstdc++-33 libXi libXtst make sysstat python3

pip3 install gdown
mv /usr/local/bin/gdown /usr/bin


#Setting kernel confiurations required by Oracle DB

MEMTOTAL=$(free -b | sed -n '2p' | awk '{print $2}') 
SHMMAX=$(expr $MEMTOTAL / 2) 
SHMMNI=4096
PAGESIZE=$(getconf PAGE_SIZE) 

#Creating Kernel parameter file for roacle
cat > /etc/sysctl.d/50-oracle.conf <<EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = $SHMMAX
kernel.shmall = $(expr \( $SHMMAX / $PAGESIZE \) \* \( $SHMMNI / 16 \))
kernel.shmmni = $SHMMNI
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

sudo sysctl --system

# Creating User for Oracle DB

read -p "Enter your Oracle Db username: " user
read -sp "Enter password for Oracle Db user: " pass

i=54321; for group in oinstall dba oper backupdba dgdba kmdba asmdba asmoper asmadmin racdba; do
groupadd -g $i $group; i=$(expr $i + 1)
done

useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,racdba -d /usr/${user} ${user}
echo "${pass}" | passwd --stdin ${user}

#Creating data directory for oracle db
mkdir -p /u01/app/`echo ${user}`
chown -R ${user}:oinstall /u01/app
chmod -R 755 /u01
sudo sed -i '/^session\s\+required\s\+pam_namespace.so/a session    required     pam_limits.so' /etc/pam.d/login

cat > /etc/security/limits.d/50-oracle.conf <<EOF
oracle   soft   nofile   1024
oracle   hard   nofile   65536
oracle   soft   nproc    2047
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
EOF

echo "Available version for installing Oracle DB in Centos 7"
echo "1. Oracle 19c"
echo "2. Oracle 21c"
echo ""
echo "Please choose between these two versions. Use '1' for Oracle 19c or '2' for Oracle 21c"
echo ""
read -p "Enter your choice: " choice

if [[ "$choice" == "1" ]]
then
    echo "#################### Installing Oracle 19c in your linux machine ####################"
    echo ""
    mkdir -p /usr/${user}/database
    cd /usr/${user}/database
    gdown --fuzzy https://drive.google.com/file/d/1HsvX7SeRyh2wDq9Q-pVWIipBXpDFkvv6/view?usp=drive_link
    unzip LINUX.X64_193000_db_home.zip
    rm -rf LINUX.X64_193000_db_home.zip
    chown -R ${user}:oinstall /usr/${user}
elif [[ "$choice" == "2" ]]
then
    echo "#################### Installing Oracle 21c in your linux machine ####################"
    echo ""
    mkdir -p /usr/${user}/database
    cd /usr/${user}/database
    gdown --fuzzy https://drive.google.com/file/d/1XS5KIS0L8bK-0lGOhf2dRvl0i8FOtMIy/view?usp=drive_link
    unzip LINUX.X64_213000_db_home.zip
    rm -rf LINUX.X64_213000_db_home.zip
    chown -R ${user}:oinstall /usr/${user}
else
    echo "Your choose wrong version to install"
fi

#Switching user for installing Oracle Db

su - ${user} <<EOF
echo "umask 022" >> ~/.bash_profile
echo "export ORACLE_BASE=/u01/app/${user}" >> ~/.bash_profile
echo "export ORACLE_HOME=/usr/${user}/database" >> ~/.bash_profile
echo "export PATH=$PATH:/usr/${user}/database/bin" >> ~/.bash_profile
source ~/.bash_profile
EOF