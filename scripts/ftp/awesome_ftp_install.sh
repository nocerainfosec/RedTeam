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

# Update package list and install necessary packages
sudo apt update -y
sudo apt install -y vsftpd jq curl

# Start and enable vsftpd service
sudo systemctl start vsftpd
sudo systemctl enable vsftpd

# Backup the default vsftpd configuration
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf_default

# Create FTP user and lock shell
sudo useradd -m -s /usr/sbin/nologin username

# Create directory for FTP and set permissions
sudo mkdir -p /srv/ftp/windows
sudo chown username:username /srv/ftp/windows
sudo usermod -d /srv/ftp/windows username

# Configure firewall rules (active and passive FTP)
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp

# Get the external IPv4 address
external_ipv4=$(curl -s ipinfo.io/json | jq -r '.ip')

# Configure vsftpd settings safely
sudo bash -c "cat > /etc/vsftpd.conf" <<EOF
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pam_service_name=ftp
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=$external_ipv4
user_sub_token=\$USER
local_root=/srv/ftp/windows
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
EOF

# Add user to chroot list
echo 'username' | sudo tee /etc/vsftpd.chroot_list > /dev/null

# Generate a random password for the FTP user
random_password=$(openssl rand -base64 12)

# Set the random password for the FTP user
echo -e "${GREEN}${CHECK} Setting a random password for username...${NC}"
echo "username:$random_password" | sudo chpasswd

# Restart vsftpd service
sudo systemctl restart vsftpd.service

# Save credentials securely
echo "FTP Credentials" > ~/ftp_credentials.txt
echo "User: username" >> ~/ftp_credentials.txt
echo "Pass: $random_password" >> ~/ftp_credentials.txt
chmod 600 ~/ftp_credentials.txt

# Display server setup summary
echo -e "\n${BLUE}--- ${YELLOW}Server Setup Summary ${BLUE}---${NC}"
echo -e "${YELLOW}${SMILEY} FTP server setup completed successfully ${NC}"
echo -e "${BLUE}${SMILEY} Random password for username: ${GREEN}$random_password${NC}"
echo -e "${YELLOW}Usage:${NC} ftp ${GREEN}username@$external_ipv4${NC}"
echo -e "${YELLOW}Credentials saved at:${NC} ~/ftp_credentials.txt\n"
