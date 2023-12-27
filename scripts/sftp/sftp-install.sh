#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emoji codes
SMILEY="😊"
ROCKET="🚀"
CHECK="✔️"

echo -e "${YELLOW}${ROCKET} Setting up your SFTP Server ${ROCKET}${NC}"

# Update package list and install OpenSSH server
sudo apt update -y 
sudo DEBIAN_FRONTEND=noninteractive apt install openssh-server -y

# Backup the default sshd configuration
sudo cp /etc/ssh/sshd_config /etc/sshd_config_default

# Create SFTP user and configure firewall rules
sudo useradd -m winupdate
sudo ufw allow 22/tcp

# Create directory for SFTP and set user home directory
sudo mkdir /srv/sftp
sudo mkdir /srv/sftp/windows
sudo usermod -d /srv/sftp/windows winupdate

# Configure sshd to allow SFTP only, chroot user, and specify home directory
echo -e "${BLUE}${CHECK} Configuring sshd...${NC}"
echo 'Match User winupdate' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    ForceCommand internal-sftp' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    ChrootDirectory /srv/sftp' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    PermitRootLogin no' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    AllowTcpForwarding no' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    X11Forwarding no' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    ForceCommand /bin/false' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo '    ChallengeResponseAuthentication yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Generate a random password for the SFTP user
random_password=$(openssl rand -base64 12)

# Set the random password for the SFTP user
echo -e "${GREEN}${CHECK} Setting a random password for winupdate...${NC}"
echo "winupdate:$random_password" | sudo chpasswd

# Get the external IPv4 address
external_ipv4=$(curl -s ipinfo.io/json | jq -r '.ip')

# Restart sshd service
sudo systemctl restart ssh

# Display server setup summary
echo -e "\n${BLUE}--- ${YELLOW}Server Setup Summary ${BLUE}---${NC}"
echo -e "${YELLOW}${SMILEY} External IPv4 address: ${GREEN}$external_ipv4${NC}"
echo -e "${YELLOW}Random password for winupdate: ${GREEN}$random_password${NC}"
echo -e "${BLUE}--- ${GREEN}${CHECK} SFTP server setup completed successfully ${BLUE}---${NC}"
echo ""
echo -e "${YELLOW}Usage:${NC} sftp ${GREEN}winupdate@$external_ipv4${NC}\n"
