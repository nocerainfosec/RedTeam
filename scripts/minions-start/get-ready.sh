#!/bin/bash

set -euo pipefail

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "[❌] Please run this script as root (e.g., with sudo)" >&2
    exit 1
fi

echo "[!] Updating and installing tools..."

apt update && apt install -y \
    wrk \
    curl \
    git \
    golang-go \
    unzip \
    python3 \
    python3-pip

echo "[!] Setting system limits..."

# Increase open file descriptors
ulimit -n 65535
echo "fs.file-max = 2097152" >> /etc/sysctl.conf
sysctl -p

echo "[!] Setting hostname..."

# Random hostname: minion-XXXX
RAND_NUM=$((1000 + RANDOM % 9000))
NEW_HOSTNAME="minion-$RAND_NUM"
hostnamectl set-hostname "$NEW_HOSTNAME"
echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts

echo
echo "[!] Setup complete. Hostname set to $NEW_HOSTNAME"
echo "[!] Your Minion is ready! Rebooting now..."

# Reboot system
reboot
