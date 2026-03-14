#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
trap 'echo "Installation failed on line $LINENO"' ERR

echo "--------------------------"
echo "Starting with Wireguard installation ..."

echo "--> Check for kernel module"
sudo modprobe wireguard
sudo modprobe iptable_raw

# Installation script
echo "--> Booting up docker container"
sudo docker compose up -d

echo "--> Enable forwarding on host machine"
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

echo "-->Waiting for WireGuard to generate keys"
CONFIG_FILE="${HOME}/services/wireguard/config/wg_confs/wg0.conf"
MAX_RETRIES=15
COUNT=0

while [ ! -f "$CONFIG_FILE" ]; do
    sleep 2
    COUNT=$((COUNT + 1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "Error: WireGuard took too long to start. Check 'docker logs wireguard' for errors."
        exit 1
    fi
done

# Show the QR code for the first peer (for easy phone setup)
echo "--> Scan this QR code with your WireGuard app:"
docker exec -it wireguard /app/show-peer 1
