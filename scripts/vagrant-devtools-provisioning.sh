#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive

echo -e "\n--- Add some repos to update our distro ---\n"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

echo -e "\n--- Installing Composer for PHP package management ---\n"
php -r "readfile('https://getcomposer.org/installer');" | sudo php -- --install-dir='/usr/bin' --filename=composer

echo -e "\n--- Installing Yarn as better alternative for NPM ---\n"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

echo -e "\n--- Installing  packages ---\n"
sudo apt-get -y update > /dev/null 2>&1;
sudo apt-get -y install nodejs yarn;
