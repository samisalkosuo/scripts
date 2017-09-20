#!/usr/bin/env bash
#
#install_wexca.sh - Install IBM Watson Explorer Advanced Edition
#
#The MIT License (MIT)
#
#Copyright (c) 2017 Sami Salkosuo
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

__current_user=$(whoami)
if [[ "$__current_user" != "root" ]] ; then
	echo "This script must be run as root."
	exit 1
fi 


# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

#clpargs config
__clpargs_file=$__dir/clpargs/clpargs.bash
if [ ! -f $__clpargs_file ];
then
  #clpargs.bash not found in subdirectory
  #try one dir above
  __clpargs_file=$__dir/../clpargs/clpargs.bash
fi

source $__clpargs_file 2> /dev/null
if [ $? -eq 0 ]; then

  #script description
  clpargs_program_description "Install WEXCA Server."

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]
  clpargs_define WEXCA_SERVER_BINARY "url or file" "URL or full path to WEXCA binary file." true
  clpargs_define INSTALL_TYPE "install type" "Installation type: master, allinone, additional." true
  clpargs_define NODE_TYPE "node type" "Node type is one of: backup, search, docproc, docproc&search, index, index&search. (required if INSTALL_TYPE is additional)." false
  clpargs_define MASTER_HOST "master node fqdn" "FQDN of master node. (required if INSTALL_TYPE is additional)." false
  
  #parse arguments
  clpargs_parse "$@"

else
  #if clpargs is not used, you can set environment variables here.
  #or elsewhere.
  echo "ERROR: clpargs.bash missing"
  exit 1

fi

#START set options
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace
#END set options

__currentDir=$(pwd)

#source functions
source $__dir/../functions/changeString.sh

#source variables for scripts
source env.sh

#some checks before installing

#if installation type is additional, node type and master host must be specified
if [[ "$INSTALL_TYPE" == "additional" ]] ; then
  #no NODE_TYPE set
  __node_type=${NODE_TYPE:-}
  if [[ -z "$__node_type" ]] ; then
	  echo "NODE_TYPE must be specified."
    exit 1
  fi 
  #no MASTER_HOST set
  __master_host=${MASTER_HOST:-}
  if [[ -z "$__master_host" ]] ; then
	  echo "MASTER_HOST must be specified."
    exit 1
  fi 
  
  if [[ "$NODE_TYPE" == "index" ]] ; then
    echo "index node requires to share the same ES_NODE_ROOT with master. NFS, GPFS or other."
  fi
  
fi 

#check is install user exists
__rv=$(cat /etc/passwd | grep $__install_user_name > /dev/null; echo $?)
if [ $__rv -eq 0 ]; then
  __create_install_user=false
else
  __create_install_user=true  
fi

#check directory
if [ -d "$__es_install_dir" ]; then
  echo "Installation directory $__es_install_dir exists."
  echo "Please delete it before installing."
  exit 1
fi

echo "Installing WEXCA..."

#__wexca_install_dir=/wexca_install_dir

mkdir -p $__wexca_install_dir
cd $__wexca_install_dir

if [ -f $WEXCA_SERVER_BINARY ];
then
   echo "Found WEXCA binary file."
   cp $WEXCA_SERVER_BINARY .
else
  echo "Downloading WEXCA binaries..."
  wget $WEXCA_SERVER_BINARY
fi
__binary_file=$(echo "${WEXCA_SERVER_BINARY##*/}")
#extract WEXCA
echo "Extracting $__binary_file to $__wexca_install_dir..."
tar -xf $__binary_file

#remove tar file
rm -f $__binary_file

#install type is: ALL_IN_ONE, DISTRIBUTED, ADDITIONAL
if [[ "$INSTALL_TYPE" == "master" ]] ; then
	__install_type=DISTRIBUTED
fi 

if [[ "$INSTALL_TYPE" == "allinone" ]] ; then
	__install_type=ALL_IN_ONE
fi 

if [[ "$INSTALL_TYPE" == "additional" ]] ; then
	__install_type=ADDITIONAL
fi 

__rsp_file_name=silent_install.properties
echo "Creating silent install response file $__rsp_file_name..."

echo "LICENSE_ACCEPTED=true" > $__rsp_file_name
echo "NODE_TYPE=$__install_type" >> $__rsp_file_name
echo "SERVER_HOSTNAME=$__fqdn" >> $__rsp_file_name
echo "INSTALL_USER_NAME=$__install_user_name" >> $__rsp_file_name
echo "CREATE_USER=${__create_install_user}" >> $__rsp_file_name
echo "INSTALL_USER_PASSWORD=${__install_user_password}" >> $__rsp_file_name
echo "INSTALL_USER_PASSWORD_CONF=${__install_user_password}" >> $__rsp_file_name
echo "USER_INSTALL_DIR=$__es_install_dir" >> $__rsp_file_name
echo "NODE_ROOT=$__node_root" >> $__rsp_file_name
echo "APP_SERVER=EMBEDDED" >> $__rsp_file_name
echo "ADMIN_HTTP_PORT=$__admin_http_port" >> $__rsp_file_name
echo "CCL_PORT=${__ccl_port}" >> $__rsp_file_name
echo "DATA_STORAGE_PORT=1527" >> $__rsp_file_name
echo "SEARCH_SERVER_PORT=8394" >> $__rsp_file_name
echo "SEARCH_APP_HTTP_PORT=${__search_http_port}" >> $__rsp_file_name

echo "Installing..."
./install.bin -i silent -f $__rsp_file_name
echo "Installing... Done. "

#start WEXCA
su - $__install_user_name -c "startccl.sh -bg" || true

#start server can be done only in master node
if [[ "$INSTALL_TYPE" != "additional" ]] ; then
  su - $__install_user_name -c "esadmin system start"
fi


if [[ "$INSTALL_TYPE" == "additional" ]] ; then
  #additional node, add this server to master
  #TODO: make this better like python rest client app

  echo "Use REST API or Admin GUI to add this node to WEXCA"

else
  #not additional, print info how to access server
  echo ""

  echo "Access WEXCA server:"
  echo "  http://${__fqdn}:${__admin_http_port}/ESAdmin"
  echo "  User    : ${__install_user_name}" 
  echo "  Password: ${__install_user_password}" 

  if [[ "$INSTALL_TYPE" != "master" ]] ; then
    echo ""
    echo "Access WEXCA search app:"
    echo "  http://${__fqdn}:${__search_http_port}/ui/search"
    echo ""
    echo "Access WEXCA analytics app:"
    echo "  http://${__fqdn}:${__search_http_port}/ui/analytics"
  fi 
fi
