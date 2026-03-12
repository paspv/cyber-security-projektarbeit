#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
trap 'echo "Installation failed on line $LINENO"' ERR

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit 1
fi

read -p "Are you sure you want to execute the home server installation script on this machine? [y/N]: " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then

    echo "Starting server setup"
  
    (cd ./docker && ./install)

    (cd ./pihole && ./install)

    (cd ./wireguard && ./install)

    (cd ./firewall && ./install)

fi
