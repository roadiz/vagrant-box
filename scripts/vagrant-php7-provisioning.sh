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

echo -e "\n--- Install base packages ---\n"
sudo locale-gen fr_FR.utf8;
# Signing key for MariaDB
# @see https://mariadb.com/kb/en/mariadb/installing-mariadb-deb-files/
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db;

echo -e "\n--- Add some repos to update our distro ---\n"
LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi
LC_ALL=C.UTF-8 sudo add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.2/ubuntu trusty main' > /dev/null 2>&1;
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
sudo apt-get -qq -f -y install git nano zip nginx mariadb-server mariadb-client curl > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Install all php7.1 extensions ---\n"
sudo apt-get -qq -f -y install php7.1 php7.1-cli php7.1-fpm php7.1-common php7.1-opcache php7.1-cli php7.1-mysql  \
                               php7.1-xml php7.1-gd php7.1-intl php7.1-imap php7.1-mcrypt php7.1-pspell \
                               php7.1-curl php7.1-recode php7.1-sqlite3 php7.1-mbstring php7.1-tidy \
                               php7.1-xsl php7.1-apcu php7.1-gd php7.1-apcu-bc php7.1-xdebug  php7.1-zip > /dev/null 2>&1;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Setting up our MySQL user, DB and test DB ---\n"
sudo mysql -uroot -p$DBPASSWD <<EOF
create database ${DBNAME};
grant all privileges on ${DBNAME}.* to '${DBUSER}'@'localhost' identified by '${DBPASSWD}';
create database ${DBNAME}_test;
grant all privileges on ${DBNAME}_test.* to '${DBUSER}'@'localhost' identified by '${DBPASSWD}';
EOF
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL creating databases${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/;realpath_cache_size = .*/realpath_cache_size = 4096k/" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 600/" /etc/php/7.1/fpm/php.ini

echo -e "\n--- Fix php-fpm startup PID path ---\n"
sudo sed -i "s/\/run\/php\/php7.1-fpm.pid/\/run\/php7.1-fpm.pid/" /etc/php/7.1/fpm/php-fpm.conf

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

#
# Do not generate default DH param and certificate
# to speed up Vagrant provisioning
#

#echo -e "\n--- Generating a unique Diffie-Hellman Group ---\n"
#sudo openssl dhparam -out /etc/nginx/certs/default.dhparam.pem 2048 > /dev/null 2>&1;
#
#echo -e "\n--- Generating a self-signed SSL certificate ---\n"
#sudo openssl req -new -newkey rsa:2048 -days 365 -nodes \
#            -x509 -subj "/C=FR/ST=Rhonealpes/L=Lyon/O=ACME/CN=localhost" \
#            -keyout /etc/nginx/certs/default.key \
#            -out /etc/nginx/certs/default.crt > /dev/null 2>&1;

echo -e "\n--- Configure PHP-FPM default pool ---\n"
sudo rm /etc/php/7.1/fpm/pool.d/www.conf;
sudo cp /vagrant/scripts/vagrant/php-pool.conf /etc/php/7.1/fpm/pool.d/www.conf;
sudo cp /vagrant/scripts/vagrant/xdebug.ini /etc/php/7.1/mods-available/xdebug.ini;
sudo cp /vagrant/scripts/vagrant/logs.ini /etc/php/7.1/mods-available/logs.ini;
sudo cp /vagrant/scripts/vagrant/opcache-recommended.ini /etc/php/7.1/mods-available/opcache-recommended.ini;
sudo phpenmod -v ALL -s ALL opcache-recommended;
sudo phpenmod -v ALL -s ALL logs;
sudo phpenmod -v ALL -s ALL xdebug;

echo -e "\n--- Restarting Nginx and PHP servers ---\n"
sudo service nginx restart > /dev/null 2>&1;
sudo service php7.1-fpm restart > /dev/null 2>&1;

##### CLEAN UP #####
sudo dpkg --configure -a  > /dev/null 2>&1; # when upgrade or install doesn't run well (e.g. loss of connection) this may resolve quite a few issues
sudo apt-get autoremove -y  > /dev/null 2>&1; # remove obsolete packages

# Set envvars
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD

export PRIVATE_IP=`/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

echo -e "\n-----------------------------------------------------------------"
echo -e "\n----------- Your Roadiz Vagrant is ready in /var/www ------------"
echo -e "\n-----------------------------------------------------------------"
echo -e "\nDo not forget to \"composer install\" and to add "
echo -e "\nyour host IP into install.php and dev.php"
echo -e "\nto get allowed in install and dev entry-points."
echo -e "\n* Type http://$PRIVATE_IP/install.php to proceed to install."
#echo -e "\n* Type https://$PRIVATE_IP/install.php to proceed using SSL (cert is not authenticated)."
echo -e "\n* MySQL User: $DBUSER"
echo -e "\n* MySQL Password: $DBPASSWD"
echo -e "\n* MySQL Database: $DBNAME"
echo -e "\n* MySQL Database for tests: ${DBNAME}_test"
echo -e "\n-----------------------------------------------------------------"
