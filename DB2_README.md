                            Steps for IBM DB2 Setup

Prerequisites:- 
    1. RAM = 16GB (Min), 24GB (Recommended)
    2. Processor = 4 cores

Note:- 
    1. This script file (db2.sh) will install ibm db2 version v11.5.8.0 in your linux machines
    2. It will ask for Username and Password, you will use this user to connect your db2 shell.Please remember it credentials.

Steps:-

1. Run this script file as root user, otherwise it will get exit.

2. Grant execute permission to script file
    ==> chmod +x db2.sh

3. Run this script file.
    ==> ./db2.sh                    (or) bash db2.sh

4. Now in first step it will ask for username. Enter your user name.Please note that you will use this user while connecting to db2 shell.

5. Now enter your user password. It will not be displayed on screen.

6. Now after some time it will prompt to enter yes/no. Please type 'yes' to accept the license.

7. Again it will prompt asking to enter which product you want to install from list-
SERVER : Install DB2 server product
CONSV : Install DB2 Connect
CLIENT : Install DB2 client
RTCL : Install DB2 runtime client

Please type SERVER for installation

8. Again it will ask if you want to install DB2 server with pureScale feature 'type yes or type no'.
    # DB2 pureScale feature enable Active cluster but for that there is additional hardware and software requirement, which you should ensure during requirement check phase.
    Please type no

9. It will take some time to complete the setup.

10. After script file exit, it will prompt some Post Installation info's. Follow those steps or follow listed steps-

    a. First switch to your db2 user
        ==> su - db2
    
    b. Stop the db2 server using -
        ==> db2stop

    c. Again start db2 server using -
        ==> db2start

    d. Now your db2 setup completed, you can use db2 shell using your db2 user.
        ==> db2
    
        #Run these queries to check db2 installation

        ==> CREATE DATABASE test
        ==> ACTIVATE DATABASE test
        ==> CONNECT TO test USER db2-user USING pass


########################################################################################################################

#If you need db2cli driver then follow these steps-

Github repo:- https://github.com/ibmdb/go_ibm_db

1. To install ibm db2 cli driver, you must have golang installed in your machine

2. Run this command to download ibm db2 cli driver installer, it will be downloaded inside your $GOPATH/src/github.com/ibmdb

  command:- go get -d github.com/ibmdb/go_ibm_db

3. Now change your working directory to $GOPATH/src/github.com/ibmdb/go_ibm_db/installer

  [root@localhost]# cd $GOPATH/src/github.com/ibmdb/go_ibm_db/installer

4. Run setup.go to install clidriver

  [root@localhost installer]# go run setup.go

5. Now you can check db2 clidriver is downloaded inside $GOPATH/src/github.com/ibmdb, and use this path for IBM_DB_HOME

  [root@localhost installer]# vim ~/.bashrc
  #Add these lines

  export IBM_DB_HOME=/root/GoProjects/src/github.com/ibmdb/clidriver
  export CGO_CFLAGS=-I$IBM_DB_HOME/include
  export CGO_LDFLAGS=-L$IBM_DB_HOME/lib
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IBM_DB_HOME/lib
  :wq

  source ~/.bashrc

