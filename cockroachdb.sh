#!/bin/bash
read -p "Please enter Cockroachdb version (e.g. v23.1.11): " VERSION

# Download and extract CockroachDB
wget https://binaries.cockroachdb.com/cockroach-${VERSION}.linux-amd64.tgz
tar -xf cockroach-${VERSION}.linux-amd64.tgz
sudo cp -i cockroach-${VERSION}.linux-amd64/cockroach /usr/bin/

# Create a CockroachDB system user
sudo useradd -r cockroachdb -s /bin/false

# Create directories for CockroachDB data and logs
sudo mkdir -p /var/lib/cockroachdb/data
sudo mkdir -p /var/lib/cockroachdb/logs

# Set ownership of the directories to the cockroachdb user
sudo chown -R cockroachdb:cockroachdb /var/lib/cockroachdb

# Create a systemd service for CockroachDB
sudo tee /etc/systemd/system/cockroachdb.service << EOF
[Unit]
Description=CockroachDB
Documentation=https://www.cockroachlabs.com/docs/
After=network.target

[Service]
ExecStart=/usr/local/bin/cockroach start --insecure --store=/var/lib/cockroachdb/data --log-dir=/var/lib/cockroachdb/logs
ExecStop=/usr/local/bin/cockroach quit --insecure --host=localhost:8080
Restart=always
User=cockroachdb
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start CockroachDB service
sudo systemctl daemon-reload
sudo systemctl start cockroachdb

# Enable CockroachDB service to start at boot
sudo systemctl enable cockroachdb

# Enabling cockroachdb default port from firewall configuration
sudo firewall-cmd --permanent --add-port=26257/tcp
sudo firewall-cmd --reload