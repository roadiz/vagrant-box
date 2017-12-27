#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive

# Latest Xenial box uses "ubuntu" default user instead of "vagrant"
# https://bugs.launchpad.net/cloud-images/+bug/1569237
USER="ubuntu"

echo -e "\n--- Add some repos to update our distro ---\n"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo -e "\n--- Installing NodeJS and NPM ---\n"
sudo apt-get -y install nodejs;

echo -e "\n--- Installing Composer for PHP package management ---\n"
php -r "readfile('https://getcomposer.org/installer');" | sudo php -- --install-dir='/usr/bin' --filename=composer

echo -e "\n--- Installing Yarn as better alternative for NPM ---\n"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y update > /dev/null 2>&1;
sudo apt-get -y install yarn;


##### CLEAN UP #####
echo -e "\n--- Clean up ---\n"
sudo dpkg --configure -a; # when upgrade or install doesnt run well (e.g. loss of connection) this may resolve quite a few issues
sudo apt-get autoremove -y; # remove obsolete packages
sudo apt-get clean -y;
sudo dd if=/dev/zero of=/EMPTY bs=1M;
sudo rm -f /EMPTY;
cat /dev/null > ~/.bash_history && history -c;