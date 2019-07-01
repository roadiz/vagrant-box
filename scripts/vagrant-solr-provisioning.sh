#!/bin/bash
#
RED='\033[0;31m'
NC='\033[0m' # No Color
export DEBIAN_FRONTEND=noninteractive

# Apache Solr
SOLR_VERSION="8.1.1"
SOLR_MIRROR="http://archive.apache.org/dist"
SOLR_ARCHIVE="/home/vagrant/solr-${SOLR_VERSION}.tgz"
SOLR_INSTALL_SCRIPT="/home/vagrant/install_solr_service.sh"
SOLR_DOWNLOAD_URI="${SOLR_MIRROR}/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz"

echo -e "\n--- Installing Open JDK 8 dependencies and repository ---\n"
sudo add-apt-repository ppa:openjdk-r/ppa;
sudo apt-get -qq update;
sudo apt-get install -qq -y openjdk-11-jre;
sudo apt-mark manual openjdk-11-jre openjdk-11-jre-headless java-common ca-certificates-java;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Downloading Apache Solr (may take a while, be patient) ---\n"
sudo wget --output-document=${SOLR_ARCHIVE} ${SOLR_DOWNLOAD_URI};
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL - Downloading ${SOLR_DOWNLOAD_URI} ${NC}\n"
   echo -e "${RED}\t!!! Please verify Solr version exists and provision again.${NC}\n"
   exit 1;
fi

echo -e "\n--- Extracting Apache Solr installer script\n";
tar xzf $SOLR_ARCHIVE solr-$SOLR_VERSION/bin/install_solr_service.sh --strip-components=2;

echo -e "\n--- Installing Apache Solr\n";
sudo bash ${SOLR_INSTALL_SCRIPT} ${SOLR_ARCHIVE};

echo -e "\n--- Create a new Solr core called \"roadiz\"\n"
sudo su -c "/opt/solr/bin/solr create_core -c roadiz" solr;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi


echo -e "\n--- Create a new Solr core called \"roadiz_test\"\n"
sudo su -c "/opt/solr/bin/solr create_core -c roadiz_test" solr;
if [ $? -eq 0 ]; then
   echo -e "\t--- OK\n"
else
   echo -e "${RED}\t!!! FAIL${NC}\n"
   echo -e "${RED}\t!!! Please destroy your vagrant and provision again.${NC}\n"
   exit 1;
fi


echo -e "\n--- Restarting Solr server ---\n"
sudo service solr restart > /dev/null 2>&1;

echo -e "\n--- Removing installer and archive ---\n"
sudo rm -rf ${SOLR_ARCHIVE} ${SOLR_INSTALL_SCRIPT};
