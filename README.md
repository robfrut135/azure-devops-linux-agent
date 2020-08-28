# azure-devops-linux-agent

## Usage

```bash
$ ./install.sh 
INFO: 2020-08-28 18:46:27,1598640387 ; main ; INIT
INFO: 2020-08-28 18:46:27,1598640387 ; parse_args ; parsing arguments
INFO: 2020-08-28 18:46:27,1598640387 ; check_args ; validating arguments
INFO: 2020-08-28 18:46:27,1598640387 ; usage ; Usage: ./install.sh -u <SYSTEM_USER> -o <ORGANIZATION> -t <TOKEN> -p <POOL> -v <VERSION> -p <PATH>
INFO: 2020-08-28 18:46:27,1598640387 ; usage ; 
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   SYSTEM_USER (required):   The system user to perform installation . Example: sysadmin 
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   ORGANIZATION (required):  Your Azure DevOps organization URL. Example: https://dev.azure.com/CONTOSO-PARTNER/ 
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   TOKEN (required):         Personal Access Token (PAT) to authenticate against Azure DevOps. Example: 09812y40yhjsdfhasjdhf
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   POOL (required):          Azure DevOps Pool name for associating this agent. 
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   VERSION (optional):       Agent version to download. By default: 2.173.0
INFO: 2020-08-28 18:46:27,1598640387 ; usage ;   PATH (optional):          Filesystem path to install Azure DevOps agent. By default: /home/hipadmin
INFO: 2020-08-28 18:46:27,1598640387 ; usage ; 
INFO: 2020-08-28 18:46:27,1598640387 ; usage ; Example: ./install.sh -u admin -o https://dev.azure.com/CONTOSO-PARTNER/ -t rdaSDY87AYDhAUSIDUHAJSHDasdasd -p my-pool
ERROR: 2020-08-28 18:46:27,1598640387 ; usage ; 
```

## Run 

```bash
hipadmin@hip-cicd00001E:~$ sudo ./install.sh -u veryadmin -o https://dev.azure.com/Contoso/ -t 0000000000000000 -p cicd
```
