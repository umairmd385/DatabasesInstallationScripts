#!/bin/bash
# Get version number from user input
read -p "Enter PostgreSQL version to install (e.g. 9.6, 10, 11): " version

# Add PostgreSQL repository
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install PostgreSQL and its dependencies
sudo yum install -y postgresql${version} postgresql${version}-server postgresql${version}-contrib

# Initialize database and start PostgreSQL service
/usr/pgsql-${version}/bin/postgresql${version}-setup initdb
sudo systemctl start postgresql-${version}
sudo systemctl enable postgresql-${version}

# Print status message
echo "PostgreSQL ${version} has been installed and started."

# Enabling default port for external access
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload