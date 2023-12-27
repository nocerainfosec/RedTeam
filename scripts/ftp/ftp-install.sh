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

echo -e "${YELLOW}${ROCKET} Setting up an Awesome FTP Server ${ROCKET}${NC}"

# Update package list and install vsftpd
sudo apt update -y
sudo apt install vsftpd -y

# Start and enable vsftpd service
sudo systemctl start vsftpd
sudo systemctl enable vsftpd

# Backup the default vsftpd configuration
sudo cp /etc/vsftpd.conf  /etc/vsftpd.conf_default

# Create FTP user and configure firewall rules
sudo useradd -m winupdate
sudo ufw allow 21/tcp
sudo ufw allow 20/tcp

# Create directory for FTP and set user home directory
sudo mkdir /srv/ftp/windows
sudo usermod -d /srv/ftp/windows ftp

# Configure vsftpd to allow writable chroot, enable write, and chroot user
echo -e "${BLUE}${CHECK} Configuring vsftpd...${NC}"
echo 'allow_writeable_chroot=YES' | sudo tee -a /etc/vsftpd.conf
echo 'winupdate' | sudo tee -a /etc/vsftpd.chroot_list
echo 'write_enable=YES' | sudo tee -a /etc/vsftpd.conf
echo 'chroot_local_user=YES' | sudo tee -a /etc/vsftpd.conf
echo 'chroot_list_file=/etc/vsftpd.chroot_list' | sudo tee -a /etc/vsftpd.conf
echo 'pam_service_name=ftp' | sudo tee -a /etc/vsftpd.conf

# Generate a random password for the FTP user
random_password=$(openssl rand -base64 12)

# Get the external IPv4 address
external_ipv4=$(curl -s ipinfo.io/json | jq -r '.ip')

# Set the random password for the FTP user
echo -e "${GREEN}${CHECK} Setting a random password for winupdate...${NC}"
echo "winupdate:$random_password" | sudo chpasswd

# Restart vsftpd service
sudo systemctl restart vsftpd.service

# Display server setup summary
echo -e "\n${BLUE}--- ${YELLOW}Server Setup Summary ${BLUE}---${NC}"
echo -e "${YELLOW}${SMILEY} FTP server setup completed successfully ${NC}"
echo -e "${BLUE}${SMILEY} Random password for winupdate: ${GREEN}$random_password${NC}"
echo -e "${YELLOW}Usage:${NC} ftp ${GREEN}winupdate@$external_ipv4${NC}\n"
