#!/bin/bash

set -e

URL=$1
TOKEN=$2
POOL=$3
VERSION=${4:-"2.173.0"}
FILE_NAME=${5:-"vsts-agent-linux-x64-2.173.0.tar.gz"}
INSTALL_PATH=${6:-"/home/azureuser/az-devops-agent"}

sudo apt-get update -y
sudo apt-get install build-essential zip -y

if [[ -f ${INSTALL_PATH}/svc.sh ]]; then
    cd ${INSTALL_PATH}
    sudo ./svc.sh stop
    sudo ./svc.sh uninstall
    ./config.sh remove --auth PAT --token ${TOKEN}
    cd ${HOME}
    rm -rf ${INSTALL_PATH}
fi

mkdir ${INSTALL_PATH} -p
cd ${INSTALL_PATH}

wget https://vstsagentpackage.azureedge.net/agent/${VERSION}/${FILE_NAME}
tar zxvf ${FILE_NAME} -C ${INSTALL_PATH}

./config.sh --url ${URL} --pool ${POOL} --agent ${HOSTNAME} --auth PAT --token ${TOKEN} --acceptTeeEula --unattended
sudo ./svc.sh install
sudo ./svc.sh start
