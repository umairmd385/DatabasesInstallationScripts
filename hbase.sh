#!/bin/bash

echo "This script will install hbase database with hadoop (Distributed Mode). In next prompts it will ask about hadoop and hbase versions"
read -p "Please enter version for hadoop installation. E.g.,(3.3.1,3.3.2): " hdver
read -p "Please enter version for Hbase installation. Eg., (2.5.1,2.5.2): " hbver
sudo yum update -y
sudo yum install wget curl java-1.8.0-openjdk-headless -y
home=`echo $(dirname $(dirname $(readlink $(readlink $(which java)))))`
sudo echo "export JAVA_HOME=${home}" >> ~/.bashrc
sudo echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
source ~/.bashrc

# Downloading hadoop tar file

sudo wget https://archive.apache.org/dist/hadoop/common/hadoop-${hdver}/hadoop-${hdver}.tar.gz
tar -xzf hadoop-${hdver}.tar.gz
sudo rm -rf hadoop-${hdver}.tar.gz
sudo mv hadoop-${hdver} /opt/hadoop

#Setting env variables and path related to hadoop
echo "export HADOOP_INSTALL=/opt/hadoop" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=/opt/hadoop" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=/opt/hadoop" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=/opt/hadoop" >> ~/.bashrc
echo "export YARN_HOME=/opt/hadoop" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=/opt/hadoop/lib/native" >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=/opt/hadoop/lib"' >> ~/.bashrc
echo "export PATH=$PATH:/opt/hadoop/bin:/opt/hadoop/sbin" >> ~/.bashrc
echo "export HADOOP_HOME=/opt/hadoop" >> ~/.bashrc

source ~/.bashrc

# Creating directories for data store of hadoop

sudo mkdir -p /data/hadoop/hdfs/datanode
sudo mkdir -p /data/hadoop/hdfs/namenode


ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod og-wx ~/.ssh/authorized_keys


# Editing hadoop env file

cat >> /opt/hadoop/etc/hadoop/hadoop-env.sh <<EOF
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which java)))))
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
EOF

cat > /opt/hadoop/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>

  <property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:9000</value>
  </property>

</configuration>
EOF

cat > /opt/hadoop/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>

  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>

  <property>
    <name>dfs.name.dir</name>
    <value>file:///data/hadoop/hdfs/namenode</value>
  </property>

  <property>
    <name>dfs.data.dir</name>
    <value>file:///data/hadoop/hdfs/datanode</value>
  </property>


</configuration>
EOF

cat > /opt/hadoop/etc/hadoop/mapred-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!-- Put site-specific property overrides in this file. -->

<configuration>

  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>

  <property>
    <name>mapreduce.jobhistory.address</name>
    <value>localhost:10020</value>
  </property>

  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>localhost:19888</value>
  </property>

  <property>
    <name>mapreduce.jobhistory.intermediate-done-dir</name>
    <value>/mr-history/tmp</value>
  </property>

  <property>
    <name>mapreduce.jobhistory.done-dir</name>
    <value>/mr-history/done</value>
  </property>


</configuration>
EOF

cat > /opt/hadoop/etc/hadoop/yarn-site.xml <<EOF
<?xml version="1.0"?>
<configuration>

  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>

  <property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>

</configuration>
EOF

#Enabling hadoop services

sudo systemctl start sshd
sudo /opt/hadoop/bin/hdfs namenode -format
sudo /opt/hadoop/sbin/start-dfs.sh
sudo /opt/hadoop/sbin/start-yarn.sh

#Installing hbase

sudo wget https://archive.apache.org/dist/hbase/${hbver}/hbase-${hbver}-bin.tar.gz
sudo tar -xzf hbase-${hbver}-bin.tar.gz
sudo rm -rf hbase-${hbver}-bin.tar.gz
sudo mv hbase-${hbver} /opt/hbase 

#Adding home path for hbase inside .bashrc file

echo "export HBASE_HOME=/opt/hbase" >> ~/.bashrc
echo "export PATH=$PATH:/opt/hbase/bin" >> ~/.bashrc
source ~/.bashrc

#Creating data directory for hbase
sudo mkdir -p /data/hbase/HFiles
sudo mkdir -p /data/hbase/zookeeper

# Modifying hbase config files 

cat >> /opt/hbase/conf/hbase-env.sh <<EOF
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which java))))) 
export HBASE_REGIONSERVERS=/opt/hbase/conf/regionservers
export HBASE_MANAGES_ZK=true
EOF

cat > /opt/hbase/conf/hbase-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>file:///data/hbase/HFiles</value>
  </property>

  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/data/hbase/Zookeeper</value>
  </property>

  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>

  <property>
    <name>hbase.tmp.dir</name>
    <value>./tmp</value>
  </property>

  <property>
    <name>hbase.unsafe.stream.capability.enforce</name>
    <value>false</value>
  </property>

  <property>
    <name>hbase.zookeeper.property.clientPort</name>
    <value>2181</value>
  </property>
</configuration>
EOF

#Starting hbase services
cd /opt/hbase/bin
./start-hbase.sh