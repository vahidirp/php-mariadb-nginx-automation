#!/bin/bash

# Step 1: Get hostname from user
read -r -p "Enter hostname: " hostname

# Step 2: Get PHP version from user
read -r -p "Enter PHP version (e.g., 7.2 or 8.3): " php_version

# Step 3: Get MariaDB version from user
read -r -p "Enter MariaDB version (e.g., 10.3 or 11.4): " mariadb_version

# Step 4: Get Email address for certbot
read -r -p "Enter your Email : " EMAIL

# It may sudo is not installed by default 
apt install sudo -y 

# Update and install essential packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y git wget curl zip unzip

# Step 5: Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Step 6: Install PHP with the specified version
echo "Installing PHP $php_version..."
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php$php_version php$php_version-fpm php$php_version-curl php$php_version-json php$php_version-xml php$php_version-xmlrpc php$php_version-gd php$php_version-intl php$php_version-soap

# Step 6.1: Update php.ini settings
php_ini_path="/etc/php/$php_version/fpm/php.ini"
echo "Updating PHP settings in php.ini..."
sudo sed -i 's/^max_input_time.*/max_input_time = 600/' "$php_ini_path"
sudo sed -i 's/^upload_max_filesize.*/upload_max_filesize = 2048M/' "$php_ini_path"

# Step 6.2: Update www.conf settings
www_conf_path="/etc/php/$php_version/fpm/pool.d/www.conf"
echo "Updating PHP-FPM settings in www.conf..."
sudo sed -i 's/^pm.max_children.*/pm.max_children = 15/' "$www_conf_path"
sudo sed -i 's/^pm.start_servers.*/pm.start_servers = 4/' "$www_conf_path"
sudo sed -i 's/^pm.min_spare_servers.*/pm.min_spare_servers = 4/' "$www_conf_path"
sudo sed -i 's/^pm.max_spare_servers.*/pm.max_spare_servers = 9/' "$www_conf_path"

# Step 7: Install MariaDB with the specified version
echo "Installing MariaDB $mariadb_version..."
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo sh -c "echo 'deb [arch=amd64,arm64,ppc64el] http://mirror.23media.com/mariadb/repo/$mariadb_version/debian $(lsb_release -cs) main' > /etc/apt/sources.list.d/mariadb.list"
sudo apt update
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
mysql_secure_installation --use-default

# Step 7.1: Create a user for phpMyAdmin in MariaDB
echo "Creating phpMyAdmin database user..."
sudo mysql -e "CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'D3H0BqU30EyFe1M2';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Step 8: Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo apt install -y phpmyadmin
sudo ln -s /usr/share/phpmyadmin /var/www/$hostname/phpmyadmin

# Step 9: Create Nginx configuration file
config_file="/etc/nginx/conf.d/${hostname}.conf"
echo "Creating Nginx configuration at $config_file..."
sudo mkdir -p /var/www/$hostname
sudo bash -c "cat > $config_file" <<EOL
server {
    listen 80;
    server_name $hostname;
    charset utf-8;
    root /var/www/$hostname;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php/php$php_version-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi.conf;
    }

    # Security configurations
    location ~ /\.ht {deny all;}
    location ~ /\.svn/  {deny all;}
    location ~ /\.git/  {deny all;}
    location ~ /\.hg/   {deny all;}
    location ~ /\.bzr/  {deny all;}

    # Deny access to sensitive files and directories
    location ~* "(base64_encode|eval|etc/passwd|shell|config|settings)\.php" {
        deny all;
    }
}
EOL

# Restart Nginx to apply changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Install SSL certificates using Certbot
echo "Installing SSL/TLS Certifications..."
echo " Stay Halal and say hello to VAHID Iranpour on Community.vahid@hotmail.com"
sudo apt install -y certbot python3-certbot-nginx
sudo ufw allow 'Nginx Full'
sudo ufw enable
certbot --nginx --agree-tos --email $EMAIL -d $hostname

echo "Setup complete!"
echo "Please put your files into /var/www/$hostname"
echo "phpMyAdmin is available at http://$hostname/phpmyadmin"
