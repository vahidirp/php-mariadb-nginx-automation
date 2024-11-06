#!/bin/bash

# Step 1: Get hostname from user
read -r -p "Enter hostname: " hostname

# Step 2: Get PHP version from user
read -r -p "Enter PHP version (e.g., 7.2 or 8.3): " php_version

# Step 3: Get MariaDB version from user
read -r -p "Enter MariaDB version (e.g., 10.3 or 11.4): " mariadb_version
# Step 4: Get Email address for certbot
read -r -p "Enter your Email : " EMAIL
# Build packages for first time 
sudo apt update
sudo apt upgrade -y
sudo apt install git wget curl zip unzip -y
# Step 5: Update system and install Nginx
echo "Updating system and installing Nginx..."
sudo apt update
sudo apt install -y nginx

# Step 6: Install PHP with the specified version
echo "Installing PHP $php_version..."
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php$php_version php$php_version-fpm php$php_version-curl php$php_version-json php$php_version-xml php$php_version-xmlrpc php$php_version-gd php$php_version-intl php$php_version-soap

# Step 7: Install MariaDB with the specified version
echo "Installing MariaDB $mariadb_version..."
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mirror.23media.com/mariadb/repo/$mariadb_version/ubuntu $(lsb_release -cs) main"
sudo apt update
sudo apt install -y mariadb-server
mysql_secure_installation --use-default
# Step 8: Create Nginx configuration file
config_file="/etc/nginx/conf.d/${hostname}.conf"
echo "Creating Nginx configuration at $config_file..."
mkdir -p /var/www/$hostname
sudo bash -c "cat > $config_file" <<EOL
server {
    listen 80;
    server_name $hostname;
    charset utf-8;
    root /var/www/$hostname;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$php_version-fpm.sock;
    }

    location ~ /\.ht    {deny all;}
    location ~ /\.svn/  {deny all;}
    location ~ /\.git/  {deny all;}
    location ~ /\.hg/   {deny all;}
    location ~ /\.bzr/  {deny all;}

    location ~*  "/(^$|readme|license|example|README|LEGALNOTICE|INSTALLATION|CHANGELOG)\.(txt|html|md)" {
        deny all;
    }

    location ~* "\.(old|orig|original|php#|php~|php_bak|save|swo|aspx?|tpl|sh|bash|bak?|cfg|cgi|dll|exe|git|hg|ini|jsp|log|mdb|out|sql|svn|swp|tar|rdf)$" {
        deny all;
    }

    location ~* "(eval\()" {
        deny all;
    }
    location ~* "(127\.0\.0\.1)" {
        deny all;
    }
    location ~* "([a-z0-9]{2000})" {
        deny all;
    }
    location ~* "(javascript\:)(.*)(\;)" {
        deny all;
    }

    location ~* "(base64_encode)(.*)(\()" {
        deny all;
    }
    location ~* "(GLOBALS|REQUEST)(=|\[|%)" {
        deny all;
    }
    location ~* "(<|%3C).*script.*(>|%3)" {
        deny all;
    }
    location ~ "(\\|\.\.\.|\.\./|~|`|<|>|\|)" {
        deny all;
    }

    location ~* "(boot\.ini|etc/passwd|self/environ)" {
        deny all;
    }

    location ~* "(thumbs?(_editor|open)?|tim(thumb)?)\.php" {
        deny all;
    }

    location ~* "(\'|\")(.*)(drop|insert|md5|select|union)" {
        deny all;
    }
    
    location ~* "(https?|ftp|php):/" {
        deny all;
    }

    location ~* "(=\\\'|=\\%27|/\\\'/?)\." {
        deny all;
    }

    location ~ "(\{0\}|\(/\(|\.\.\.|\+\+\+|\\\"\\\")" {
        deny all;
    }

    location ~ "(~|`|<|>|:|;|%|\\|\s|\{|\}|\[|\]|\|)" {
        deny all;
    }

    location ~* "/(=|\$&|_mm|(wp-)?config\.|cgi-|etc/passwd|muieblack)" {
        deny all;
    }

    location ~* "(&pws=0|_vti_|\(null\)|\{\$itemURL\}|echo(.*)kae|etc/passwd|eval\(|self/environ)" {
        deny all;
    }

    location ~* "/(^$|mobiquo|phpinfo|shell|sqlpatch|thumb|thumb_editor|thumbopen|timthumb|webshell|config|settings|configuration)\.php" {
        deny all;
    }

}

EOL

# Restart Nginx to apply changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Install SSL certifications
echo "Install SSL/TLS Certifications ..."
echo " Stay Halal and say hello to VAHID Iranpour on Community.vahid@hotmail.com"
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
ufw enable
ufw allow 80/tcp
ufw allow 443/tcp
ufw reload
certbot --nginx --agree-tos --email $EMAIL -d $hostname

echo "Setup complete!"
echo "Please put your files into /var/www/$hostname"
