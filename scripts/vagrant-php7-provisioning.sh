#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

RED='\033[0;31m'
NC='\033[0m' # No Color

DBHOST="localhost"
DBNAME="roadiz"
DBUSER="roadiz"
DBPASSWD="roadiz"

echo -e "\n--- Okay, installing now... ---\n"
sudo apt-get -qq update;
sudo apt-get -qq -y install build-essential software-properties-common;

echo -e "\n--- Install base packages ---\n"
# Signing key for MariaDB
# @see https://mariadb.com/kb/en/mariadb/installing-mariadb-deb-files/
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8;

echo -e "\n--- Add some repos to update our distro ---\n"
LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi
LC_ALL=C.UTF-8 sudo add-apt-repository 'deb http://ftp.utexas.edu/mariadb/repo/10.2/ubuntu xenial main' > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi


# Use latest nginx for HTTP/2
sudo cp -a /vagrant/scripts/vagrant/sources.list.d/nginx.list /etc/apt/sources.list.d/nginx.list;
wget -q -O- http://nginx.org/keys/nginx_signing.key | sudo apt-key add - > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL nginx key signing ${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Updating packages list ---\n"
sudo apt-get -qq update;
sudo apt-get -qq -y upgrade > /dev/null 2>&1;

echo -e "\n--- Install MySQL specific packages and settings ---\n"
sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password_again password $DBPASSWD"

echo -e "\n--- Install base servers and packages ---\n"
sudo apt-get -qq -y install git htop nano zsh zip nginx mariadb-server mariadb-client curl;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Install all php7.2 extensions ---\n"
sudo apt-get -qq -y install php7.2 php7.2-cli php7.2-fpm php7.2-common php7.2-opcache php7.2-cli php7.2-mysql  \
                               php7.2-xml php7.2-gd php7.2-intl php7.2-imap php-mcrypt php7.2-pspell \
                               php7.2-curl php7.2-recode php7.2-sqlite3 php7.2-mbstring php7.2-tidy \
                               php7.2-xsl php-apcu php-apcu-bc php7.2-zip php-xdebug;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Setting up our MySQL user, DB and test DB ---\n"
sudo mysql -uroot -p$DBPASSWD <<EOF
CREATE DATABASE ${DBNAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASSWD}';
CREATE DATABASE ${DBNAME}_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ${DBNAME}_test.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASSWD}';
EOF
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL creating databases${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/fpm/php.installing
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;realpath_cache_size = .*/realpath_cache_size = 4096k/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 600/" /etc/php/7.2/fpm/php.ini

echo -e "\n--- Fix php-fpm startup PID path ---\n"
sudo sed -i "s/\/run\/php\/php7.2-fpm.pid/\/run\/php7.2-fpm.pid/" /etc/php/7.2/fpm/php-fpm.conf

echo -e "\n--- We definitly need to upload large files ---\n"
sed -i "s/server_tokens off;/server_tokens off;\\n\\tclient_max_body_size 256M;/" /etc/nginx/nginx.conf

echo -e "\n--- Configure Nginx virtual host for Roadiz and phpmyadmin ---\n"
sudo mkdir /etc/nginx/snippets;
sudo mkdir /etc/nginx/certs;
sudo mkdir /etc/nginx/sites-available;
sudo rm /etc/nginx/conf.d/default.conf;
sudo cp /vagrant/scripts/vagrant/nginx-conf.conf /etc/nginx/nginx.conf;
sudo cp /vagrant/scripts/vagrant/nginx-vhost.conf /etc/nginx/sites-available/default;
sudo cp /vagrant/scripts/vagrant/roadiz-nginx-include.conf /etc/nginx/snippets/roadiz.conf;

echo -e "\n--- Configure PHP-FPM default pool ---\n"
sudo rm /etc/php/7.2/fpm/pool.d/www.conf;
sudo cp /vagrant/scripts/vagrant/php-pool.conf /etc/php/7.2/fpm/pool.d/www.conf;
#sudo cp /vagrant/scripts/vagrant/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini;
sudo cp /vagrant/scripts/vagrant/logs.ini /etc/php/7.2/mods-available/logs.ini;
sudo cp /vagrant/scripts/vagrant/opcache-recommended.ini /etc/php/7.2/mods-available/opcache-recommended.ini;
sudo phpenmod -v 7.2 -s ALL opcache-recommended;
sudo phpenmod -v 7.2 -s ALL logs;
#sudo phpenmod -v 7.2 -s ALL xdebug;

echo -e "\n--- Restarting Nginx and PHP servers ---\n"
sudo usermod -aG www-data ${USER};
sudo service nginx restart > /dev/null 2>&1;
sudo service php7.2-fpm restart > /dev/null 2>&1;

# Set envvars
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD

