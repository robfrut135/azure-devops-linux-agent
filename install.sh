#!/bin/bash

set -e

DATE_FORMAT="+%Y-%m-%d %H:%M:%S,%s"

function log_info(){
    DATE=$(date "${DATE_FORMAT}")
    echo "INFO: ${DATE} ; "${FUNCNAME[1]}" ; ${1}"
}

function log_error(){
    DATE=$(date "${DATE_FORMAT}")
    echo "ERROR: ${DATE} ; "${FUNCNAME[1]}" ; ${1}"
    exit 101
}

function check_args(){
    log_info "validating arguments"
    if [[ -z "${URL}" || -z "${TOKEN}" || -z "${POOL}" ]]; then
        usage
    fi
}

function usage() {
    log_info "Usage: $0 -u <URL> -t <TOKEN> -p <POOL> -v <VERSION> -p <PATH>"
    log_info ""
    log_info "  URL (required):     Your organization URL. Example: https://dev.azure.com/CONTOSO-PARTNER/ "
    log_info "  TOKEN (required):   Personal Access Token (PAT) to authenticate against Azure DevOps. Example: 09812y40yhjsdfhasjdhf"
    log_info "  POOL (required):    Azure DevOps Pool name for associating this agent. "
    log_info "  VERSION (optional): Agent version to download. By default: 2.173.0"
    log_info "  PATH (optional):    Filesystem path to install Azure DevOps agent. By default: ${HOME}"
    log_info ""
    log_info "Example: $0 -u https://dev.azure.com/CONTOSO-PARTNER/ -t rdaSDY87AYDhAUSIDUHAJSHDasdasd -p my-pool"
    log_error ""
}

function parse_args(){
    log_info "parsing arguments"

    while [[ $# -gt 0 ]]; do
        key="$1"
        case "$key" in
            -u|--url)
                shift
                URL="$1"
            ;;
            -u=*|--url=*)
                URL="${key#*=}"
            ;;

            -t|--token)
                shift
                TOKEN="$1"
            ;;
            -t=*|--token=*)
                TOKEN="${key#*=}"
            ;;

            -p|--pool)
                shift
                POOL="$1"
            ;;
            -p=*|--pool=*)
                POOL="${key#*=}"
            ;;

            -v|--version)
                shift
                VERSION="$1"
            ;;
            -v=*|--version=*)
                VERSION="${key#*=}"
            ;;

            -p|--path)
                shift
                INSTALL_PATH="$1"
            ;;
            -p=*|--path=*)
                INSTALL_PATH="${key#*=}"
            ;;

            *)
                log_error "Unknown option '$key'"
            ;;
        esac
        shift
    done
}
log_info "INIT"

parse_args "$@"
check_args

VERSION=${VERSION:-"2.173.0"}
FILE_NAME="vsts-agent-linux-x64-${VERSION}.tar.gz"
INSTALL_PATH=${INSTALL_PATH:-"${HOME}/az-devops-agent"}

log_info "updating system repositories"
sudo apt-get update -y

log_info "installing core packages"
sudo apt-get install build-essential zip -y

log_info "checking current installation"
if [[ -f ${INSTALL_PATH}/svc.sh ]]; then
    cd ${INSTALL_PATH}
    sudo ./svc.sh stop
    sudo ./svc.sh uninstall
    ./config.sh remove --auth PAT --token ${TOKEN}
    cd ${HOME}
    rm -rf ${INSTALL_PATH}
fi

log_info "cleaning directories"
mkdir ${INSTALL_PATH} -p
cd ${INSTALL_PATH}

log_info "downloading Azure DevOps agent package"
wget https://vstsagentpackage.azureedge.net/agent/${VERSION}/${FILE_NAME}
tar zxvf ${FILE_NAME} -C ${INSTALL_PATH}

log_info "configuring Azure DevOps agent"
./config.sh --url ${URL} --pool ${POOL} --agent ${HOSTNAME} --auth PAT --token ${TOKEN} --acceptTeeEula --unattended

log_info "install Azure DevOps agent system service"
sudo ./svc.sh install

log_info "starting Azure DevOps agent"
sudo ./svc.sh start

log_info "END"
