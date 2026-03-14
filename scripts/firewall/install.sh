#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
trap 'echo "Installation failed on line $LINENO"' ERR

echo "--------------------------"
echo "Starting with Firewall configuration ..."

echo "--> Force UFW reset"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default deny routed   # Critical for Docker security
sudo ufw default allow outgoing

echo "--> Allow SSH from LAN"
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp comment 'Allow SSH from LAN'

echo "--> Allow Wireguard"
sudo ufw allow 51820/udp comment 'WireGuard VPN'

echo "--> Allow DNS & Web UI (ONLY via VPN)"
# We only allow traffic if it's coming from the WireGuard internal subnet
sudo ufw route allow from 10.13.13.0/24 to any port 53 comment 'VPN Clients to DNS'
sudo ufw route allow from 10.13.13.0/24 to any port 8080 proto tcp comment 'VPN Clients to Pi-hole UI'

echo "--> Enable firewall"
sudo ufw --force enable

echo "--> Prevent Docker bypassing the firewall"
# Ensure wget is installed
sudo apt-get install -y wget

# Download ufw-docker properly
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker

# Install the iptables hooks
sudo /usr/local/bin/ufw-docker install

# EXPLICITLY check the status
sudo ufw status

echo "--> Restart firewall"
sudo systemctl restart ufw