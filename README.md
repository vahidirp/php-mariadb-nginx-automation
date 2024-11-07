# Start your service for php web hosting in my style, My pretty.
PHP Web Backend automation install.

Just enter version of basic services that you want.

Don't forgot to running "chmod +x bashscript_file.sh" before running it.

Please make issues if see problem or bugs, I will be happy to help improve this project.

## Services : 
* 1- Nginx latest version with config based on your hostname for PHP-FPM ( the directory should you put your files on it is : /var/www/your domain that you enter )

* 2- PHP version you enter with extensions : FPM - CURL - JSON - XML - XMLRPC - GD - INTL - SOAP and do recommended config on php.ini and www.conf (php-fpm)

* 3- MariaDB version you enter with config as default settings ( not root password you can setup from first with "mysql_secure_installation")
* 3.1- Install PHP My Admin
  
* 4- Let's Encrypt with auto installation certificate 

### Big Hint maybe : 
You may encounter problems during the installation process due to the unavailability of some mirrors or repositories due to downtime or sanctions or filters. In this case, you can contact me through my email and LinkedIn.

## PHP My Admin : 

yourdomain.tld/phpmyadmin
defaults =>
Username : phpmyadmin
Password : D3H0BqU30EyFe1M2

If you want to change url of phpmyadmin you can rename phpmyadmin directory in /var/www/$domain/phpmyadmin

# Change Logs :

### v1.2:
* Add PMA Installation
* Add PHP.ini and www.conf recommended setting update
