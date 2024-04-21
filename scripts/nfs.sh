#!/bin/bash
#
# Setup for PersistentVolume(NFS) servers

set -euxo pipefail

# Variable Declaration

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

sudo systemctl restart systemd-resolved

# Install NFS Server Package
sudo apt-get update -y
sudo apt-get install nfs-kernel-server -y

# Set up the shared directory and nfs options
sudo mkdir -p /data
sudo chown -R nobody:nogroup /data
sudo chmod 777 /data
cat >> /etc/exports << EOF
/data  10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
EOF
sudo exportfs -av
sudo systemctl restart nfs-server

# Set up the Local firewall
sudo ufw allow from 10.0.0.0/24 to any port nfs
sudo ufw reload

# Change server time zone to Asia/Seoul.
sudo timedatectl set-timezone Asia/Seoul
