#!/bin/bash
# https://github.com/chef/bento/blob/master/ubuntu/scripts/cleanup.sh


# Delete all Linux headers
sudo dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs sudo apt-get -y purge;

# Remove specific Linux kernels, such as linux-image-3.11.0-15-generic but
# keeps the current kernel and does not touch the virtual packages,
# e.g. 'linux-image-generic', etc.
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-.*-generic' \
    | grep -v `uname -r` \
    | xargs sudo apt-get -y purge;

# Delete Linux source
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs sudo apt-get -y purge;

# Delete development packages
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev$' \
    | xargs sudo apt-get -y purge;

# delete docs packages
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-doc$' \
    | xargs sudo apt-get -y purge;

# Delete X11 libraries
sudo apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6;

# Delete obsolete networking
sudo apt-get -y purge ppp pppconfig pppoeconf;

# Delete oddities
sudo apt-get -y purge popularity-contest installation-report command-not-found command-not-found-data friendly-recovery bash-completion fonts-ubuntu-font-family-console laptop-detect;

# Delete the massive firmware packages
sudo apt-get -y purge linux-firmware

sudo apt-get -y autoremove;
sudo apt-get -y clean;

# Remove docs
sudo rm -rf /usr/share/doc/*

# Remove caches
sudo find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
sudo find /var/log/ -name *.log -exec rm -f {} \;

