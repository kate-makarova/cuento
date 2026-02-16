#!/bin/bash

# Exit on error
set -e

# Update and upgrade system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install necessary tools
echo "Installing dependencies..."
sudo apt install -y curl git ufw debian-keyring debian-archive-keyring apt-transport-https

# Install MariaDB
echo "Installing MariaDB..."
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation (automated)
# This sets the root password to 'root' (CHANGE THIS IN PRODUCTION!) and removes insecure defaults
sudo mysql_secure_installation <<EOF

y
root
root
y
y
y
y
EOF

# Create database and user
echo "Creating database and user..."
sudo mysql -u root -proot <<EOF
CREATE DATABASE IF NOT EXISTS cuento;
CREATE USER IF NOT EXISTS 'cuento'@'localhost' IDENTIFIED BY 'cuento_password';
GRANT ALL PRIVILEGES ON cuento.* TO 'cuento'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install Caddy
echo "Installing Caddy..."
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

# Create application directories
echo "Creating application directories..."
sudo mkdir -p /var/www/frontend
sudo mkdir -p /var/www/backend
sudo chown -R www-data:www-data /var/www/frontend
sudo chown -R www-data:www-data /var/www/backend
sudo chmod -R 755 /var/www

# Setup Caddyfile
echo "Configuring Caddy..."
# Assuming Caddyfile is in the same directory as this script or will be uploaded
# For now, we'll create a placeholder or copy if it exists
if [ -f "Caddyfile" ]; then
    sudo cp Caddyfile /etc/caddy/Caddyfile
else
    echo "Warning: Caddyfile not found in current directory. Please upload it to /etc/caddy/Caddyfile manually."
fi
sudo systemctl reload caddy

# Setup Backend Service
echo "Setting up Backend Service..."

# Create a dedicated user for the backend service (optional but recommended)
if ! id "cuento" &>/dev/null; then
    sudo useradd -r -s /bin/false cuento
fi

# Create systemd service file
cat <<EOF | sudo tee /etc/systemd/system/cuento-backend.service
[Unit]
Description=Cuento Backend Service
After=network.target mariadb.service

[Service]
User=cuento
Group=cuento
WorkingDirectory=/var/www/backend
ExecStart=/var/www/backend/cuento-server
Restart=always
RestartSec=5
Environment="GIN_MODE=release"
Environment="DB_DSN=cuento:cuento_password@tcp(localhost:3306)/cuento?parseTime=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable cuento-backend

# Setup Firewall (UFW)
echo "Configuring Firewall..."
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

echo "Setup complete! Please ensure you:"
echo "1. Upload your Caddyfile to /etc/caddy/Caddyfile if not done."
echo "2. Deploy your frontend files to /var/www/frontend."
echo "3. Deploy your backend binary to /var/www/backend/cuento-server."
echo "4. IMPORTANT: Change the default database passwords in this script and in the service file for production!"
echo "5. Start the backend service: sudo systemctl start cuento-backend"
