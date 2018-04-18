#!/bin/bash
############## Installing for Centos 7, Ubuntu 16.04 ##############
############## Variables ##############
#export red='\033[0;91m'
#export green='\033[0;92m'
#export yellow='\033[0;93m'
#export nc='\033[0m'

export red=$(tput setaf 1)
export green=$(tput setaf 2)
export nc=$(tput sgr0)

# Update installed package
#M_PLATFORM=`python -mplatform |grep -Eo "Ubuntu"`

M_PLATFORM_UBUNTU=`python -mplatform |grep -Eo "Ubuntu"`
M_PLATFORM_CENTOS=`python -mplatform |grep -Eo "centos"`
M_PLATFORM_FEDORA=`python -mplatform |grep -Eo "fedora"`

if [[ $EUID -ne 0 ]]; then
  echo -e "${red}[ERROR ]${nc} Please run this script with root permission"
  if [[ $M_PLATFORM_UBUNTU == "Ubuntu" ]]; then
    echo -e "[INFO  ] Type: \"sudo -s\" before running script"
    exit 1;
  elif [[ $M_PLATFORM_CENTOS == "centos" ]]; then
    echo -e "[INFO  ] Type: \"su -\" before running script"
    exit 1;
  elif [[ $M_PLATFORM_FEDORA == "fedora" ]]; then
    echo -e "[INFO  ] Type: \"su -\" before running script"
    exit 1;
  else
    echo -e "${red}[ERROR ]${nc}This could not ecognize any distro of Linux, please check it again"
    exit 1;
  fi 
fi

EXITCODE=0

function CHECK_STATUS {
  if [[ $EXITCODE == 0 ]]; then
    echo -e " ${green}DONE${nc}"
  else
    echo -e " ${red}ERROR${nc}"
    echo "[INFO  ] Please check error login /tmp/install_ansible.log"
    exit 1;
  fi
}

function OS_UPDATE {
  echo -n "[INFO  ] Updating OS: "
  if [[ $M_PLATFORM_UBUNTU == "Ubuntu" ]]; then
    apt-get update -y &>> /tmp/install_ansible.log 
  elif [[ $M_PLATFORM_CENTOS == "centos" ]]; then
    yum update -y &>> /tmp/install_ansible.log 
  fi
  EXITCODE=$?
  CHECK_STATUS
}

function INSTALL_PACKAGES {
  echo "[INFO  ] Install Packages:"
  if [[ $M_PLATFORM_UBUNTU == "Ubuntu" ]]; then
    echo -n "- Installing Python, Python-pip: "
    apt-get -y install python python-pip &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

    echo -n "[INFO  ] - Installing Ansible: "
    apt-get -y install ansible &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

    echo -n "[INFO  ] - Installing GIT: "
    apt-get -y install git &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

  elif [[ $M_PLATFORM_CENTOS == "centos" ]]; then
    echo -n "[INFO  ] - Installing Epel Repository: "
    yum -y install epel-release &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

    echo -n "[INFO  ] - Installing Python, Python-pip package: "
    yum -y install python python-pip > /dev/null 
    EXITCODE=$?
    CHECK_STATUS

    echo -n "[INFO  ] - Installing Ansible package: "
    yum -y install ansible &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

    echo -n "[INFO  ] - Installing GIT package: "
    yum -y install git &>> /tmp/install_ansible.log 
    EXITCODE=$?
    CHECK_STATUS

  fi
}


function PRE_CONFIG {
  echo -n "[INFO  ] Config default folder for Ansible (/opt): "
  chmod -R 777 /opt
  EXITCODE=$?
  CHECK_STATUS
}

function INSTALL_REQUIREMENT {
  echo -n "[INFO  ] Install jxmlease: "
  pip install jxmlease &>> /tmp/install_ansible.log 
  EXITCODE=$?
  CHECK_STATUS
  
  echo -n "[INFO  ] Install Junox-PyEZ Module: "
  pip install junos-eznc &>> /tmp/install_ansible.log 
  EXITCODE=$?
  CHECK_STATUS
  
}

function GIT_CLONE {
  echo -n "[INFO  ] Git Clone Demo Ansible Repository: "
  git clone https://github.com/tuhoanganh/SVTECH-Junos-Ansible.git /opt/SVTECH-Junos-Ansible &>> /tmp/install_ansible.log 
  echo -e " ${green}DONE${nc}"
}

OS_UPDATE
INSTALL_PACKAGES
PRE_CONFIG
INSTALL_REQUIREMENT
GIT_CLONE

