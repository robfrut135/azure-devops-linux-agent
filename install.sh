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
    if [[ -z "${SYSTEM_USER}" || -z "${ORGANIZATION}" || -z "${TOKEN}" || -z "${POOL}" ]]; then
        usage
    fi
}

function usage() {
    log_info "Usage: $0 -u <SYSTEM_USER> -o <ORGANIZATION> -t <TOKEN> -p <POOL> -v <VERSION> -p <PATH>"
    log_info ""
    log_info "  SYSTEM_USER (required):   The system user to perform installation . Example: sysadmin "
    log_info "  ORGANIZATION (required):  Your Azure DevOps organization URL. Example: https://dev.azure.com/CONTOSO-PARTNER/ "
    log_info "  TOKEN (required):         Personal Access Token (PAT) to authenticate against Azure DevOps. Example: 09812y40yhjsdfhasjdhf"
    log_info "  POOL (required):          Azure DevOps Pool name for associating this agent. "
    log_info "  VERSION (optional):       Agent version to download. By default: 2.173.0"
    log_info "  PATH (optional):          Filesystem path to install Azure DevOps agent. By default: ${HOME}"
    log_info ""
    log_info "Example: $0 -u admin -o https://dev.azure.com/CONTOSO-PARTNER/ -t rdaSDY87AYDhAUSIDUHAJSHDasdasd -p my-pool"
    log_error ""
}

function parse_args(){
    log_info "parsing arguments"

    while [[ $# -gt 0 ]]; do
        key="$1"
        case "$key" in
            -u|--user)
                shift
                export SYSTEM_USER="$1"
            ;;
            -u=*|--user=*)
                export SYSTEM_USER="${key#*=}"
            ;;

            -o|--organization)
                shift
                export ORGANIZATION="$1"
            ;;
            -o=*|--organization=*)
                export ORGANIZATION="${key#*=}"
            ;;

            -t|--token)
                shift
                export TOKEN="$1"
            ;;
            -t=*|--token=*)
                export TOKEN="${key#*=}"
            ;;

            -p|--pool)
                shift
                export POOL="$1"
            ;;
            -p=*|--pool=*)
                export POOL="${key#*=}"
            ;;

            -v|--version)
                shift
                export VERSION="$1"
            ;;
            -v=*|--version=*)
                export VERSION="${key#*=}"
            ;;

            -p|--path)
                shift
                export INSTALL_PATH="$1"
            ;;
            -p=*|--path=*)
                export INSTALL_PATH="${key#*=}"
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

export VERSION=${VERSION:-"2.173.0"}
export FILE_NAME="vsts-agent-linux-x64-${VERSION}.tar.gz"
export INSTALL_PATH=${INSTALL_PATH:-"/opt/az-devops-agent"}

log_info "updating system repositories"
apt-get update -y

log_info "installing core packages"
apt-get install build-essential zip -y

log_info "installing pip"
apt-get install python3-pip -y

log_info "checking current installation"
if [[ -f ${INSTALL_PATH}/svc.sh ]]; then
    cd ${INSTALL_PATH}
    sudo ./svc.sh stop
    sudo ./svc.sh uninstall
    su -p ${SYSTEM_USER} -c 'cd ${INSTALL_PATH} && ./config.sh remove --auth PAT --token ${TOKEN}'
    cd ${HOME}
    rm -rf ${INSTALL_PATH}
fi

log_info "cleaning directories"
mkdir ${INSTALL_PATH} -p
cd ${INSTALL_PATH}

log_info "downloading Azure DevOps agent package"
wget https://vstsagentpackage.azureedge.net/agent/${VERSION}/${FILE_NAME}
tar zxvf ${FILE_NAME} -C ${INSTALL_PATH}
chown -R ${SYSTEM_USER} ${INSTALL_PATH}

log_info "configuring Azure DevOps agent"
su -p ${SYSTEM_USER} -c 'cd ${INSTALL_PATH} && ./config.sh --url ${ORGANIZATION} --pool ${POOL} --agent ${HOSTNAME} --auth PAT --token ${TOKEN} --acceptTeeEula --unattended --runAsAutoLogon'

log_info "install Azure DevOps agent system service"
./svc.sh install

log_info "starting Azure DevOps agent"
./svc.sh start

log_info "END"
