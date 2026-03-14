#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
trap 'echo "Installation failed on line $LINENO"' ERR

echo "--------------------------"
echo "Starting with Pi-hole installation ..."

echo "--> Preparing Host for Pi-hole (Freeing Port 53)"
# Create a file backup 
cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak

# Update the DNSStubListener setting
if grep -q "DNSStubListener=" /etc/systemd/resolved.conf; then
    sed -i 's/^#*DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf
else
    echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
fi

# Restart systemd-resolved to apply changes
systemctl restart systemd-resolved

# Fix the resolv.conf symlink
# We point it to the 'static' file maintained by systemd-resolved
rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Installation script
echo "--> Booting up docker container"
sudo docker compose up -d