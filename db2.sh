#!/bin/bash

echo "This script file will install IBM DB2 version v11.5.8.0 in your linux machine"

#Verifying user to be root user for running this script file
WHOAMI=$(whoami)
if [ "$WHOAMI" != "root" ]; then
    echo must run as root
    exit -1
fi

# Asking for IBM DB2 user and password from user
read -p "Enter your user name for IBM db2 eg(db2user): " user
read -sp "Enter password for your user: " pass

#Installing Some packages required by DB2
yum groupinstall -y "Development Tools"
yum install -y wget curl python3 sudo passwd pam-devel ksh ncurses-libs file libaio libstdc++-devel libstdc++ nscd libXtst.x86_64 libXtst-devel.x86_64
yum clean all

#Installing gdown tool for downloading ibm db2 package remote location
pip3 install gdown
mv /usr/local/bin/gdown /usr/bin
gdown --fuzzy https://drive.google.com/file/d/16YXlAfJoQiTtGUTGq3AT2omLm4nYnFtJ/view?usp=drive_link

#Setting some Constant Values
DB2_SOURCE=v11.5.8_linuxx64_server_dec.tar.gz
DB2_HOME=/home/${user}/sqllib
DB2_DATA=/home/${user}/data

#Adding Default IBM DB2 user 
groupadd db2iadm1
useradd -G db2iadm1 ${user}
echo "${pass}" | passwd --stdin ${user}

systemctl start nscd
systemctl enable nscd

#Adding port in firewall

firewall-cmd --permanent --add-port=50000/tcp
firewall-cmd --reload

mv $DB2_SOURCE /tmp
cd /tmp
tar -xzf $DB2_SOURCE

su - ${user} -c "/tmp/server_dec/db2_install -b /home/${user}/sqllib"
echo "/home/${user}/sqllib/db2profile" >> /home/${user}/.bash_profile

sed -ri 's/(ENABLE_OS_AUTHENTICATION=).*/\1YES/g' $DB2_HOME/instance/db2rfe.cfg
sed -ri 's/(RESERVE_REMOTE_CONNECTION=).*/\1YES/g' $DB2_HOME/instance/db2rfe.cfg
sed -ri "s/^\\*(SVCENAME=db2c_\${user})/\\1/g" $DB2_HOME/instance/db2rfe.cfg
sed -ri 's/^\*(SVCEPORT)=48000/\1=50000/g' $DB2_HOME/instance/db2rfe.cfg

mkdir $DB2_DATA
chown -R ${user}:db2iadm1 $DB2_DATA

su - ${user} -c "db2start && db2 UPDATE DBM CFG USING DFTDBPATH $DB2_HOME IMMEDIATE && db2set DB2COMM=TCPIP"
su - ${user} -c "db2stop force"

su - ${user} -c "db2iauto -on ${user}"

mkdir -p /var/db2
$DB2_HOME/bin/db2fmcu -u -p $DB2_HOME/bin/db2fmcd
su - ${user} -c "$DB2_HOME/bin/db2fm -i ${user} -U"
su - ${user} -c "$DB2_HOME/bin/db2fm -i ${user} -u"
su - ${user} -c "$DB2_HOME/bin/db2fm -i ${user} -f on"

$DB2_HOME/bin/db2fmcu -d
cat > /etc/systemd/system/db2fmcd.service << EOF
[Unit]
Description=DB2V105
[Service]
ExecStart=/home/${user}/sqllib/bin/db2fmcd
Restart=always
[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl start db2fmcd
systemctl enable db2fmcd

cd /home/${user}/sqllib/instance
./db2rfe -f ./db2rfe.cfg

cd /home/${user}/sqllib/security
chown root:root db2chpw
chown root:root db2ckpw
chmod u+s db2chpw
chmod u+s db2ckpw

rm -rf /tmp/server_dec
rm -f /tmp/$DB2_SOURCE
echo ""
echo ""
echo "##################################################################################################"
echo "#                                                                                                #"
echo "#                                 Post Installation Info                                         #"
echo "#                                                                                                #"
echo "##################################################################################################"
echo "#                                         Info's                                                 #"
echo "#                                                                                                #"
echo "# Created user: ${user}                                                                          #"
echo "# Password: ${pass}                                                                              #"
echo "# Please switch to your user: ${user}.                                                           #"
echo "# Using command 'su - ${user}'                                                                   #"
echo "# Then stop your db2 service by using                                                            #"
echo "# command 'db2stop'                                                                              #"
echo "# Again start your db2 service by using                                                          #"
echo "# command 'db2start'                                                                             #"
echo "#                                                                                                #"
echo "# Now you can get shell using 'db2' command                                                      #"
echo "##################################################################################################"