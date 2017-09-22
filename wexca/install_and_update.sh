#!/usr/bin/env bash
#
#install_and_update.sh - Install and update IBM Watson Explorer Content Analytics. Tested with WEXCA 11.0.2 and update 11.0.2.1.
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
  clpargs_program_description "Install WEXCA all-in-one master server."

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]
  clpargs_define WEXCA_SERVER_BINARY "file" "Full path to WEXCA binary file." true
  clpargs_define WEXCA_UPDATE_BINARY "file" "Full path to WEXCA update binary file." true
  clpargs_define INSTALL_TYPE "install type" "Installation type: master, allinone, additional." true
  
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

#install prereqs
echo "Installing prereq libs..."
yum -y install unzip compat-libstdc++-33.i686 libstdc++.i686 zlib-devel.i686 libXext.i686 libXft.i686 libXi.i686
echo "Installing prereq libs... Done."

#settings for WEXCA install
#settings
#this is tmp directory for install
__wexca_install_dir=/wexca_install_dir

#this is where product binaries are installed
__es_install_dir=/opt/IBM/es/
#this is where data is
__node_root=/opt/IBM/esData
#WEXCA admin user and password
__install_user_name=esadmin
__install_user_password=passw0rd
#default ports
__ccl_port=6002
__admin_http_port=8390
__search_http_port=8393
#hostname
__fqdn=$(hostname -f)

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

#source functions
source $__dir/../functions/changeString.sh

#some checks before installing

#check if install user exists
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
cp $WEXCA_SERVER_BINARY .
__binary_file=$(echo "${WEXCA_SERVER_BINARY##*/}")
#extract WEXCA
echo "Extracting $__binary_file to $__wexca_install_dir..."
tar -xf $__binary_file
#remove tar file
rm -f $__binary_file
#copy update file to update dir
mkdir -p $__wexca_install_dir/update
cd $__wexca_install_dir/update
cp $WEXCA_UPDATE_BINARY .
__binary_file=$(echo "${WEXCA_UPDATE_BINARY##*/}")
#extract WEXCA
echo "Extracting $__binary_file to $__wexca_install_dir/update..."
tar -xf $__binary_file
#remove tar file
rm -f $__binary_file
cd $__wexca_install_dir


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

echo "Installing... If this fails, silent install log is here: /tmp/silentInstallExit.log"
./install.bin -i silent -f $__rsp_file_name
echo "Installing... Done. "

#stop WEXCA
su - $__install_user_name -c "stopccl.sh " 

echo "Updating WEXCA..."
#update directory and update file extracted earlier in this script
cd update
__rsp_file_name=silent_update.properties
echo "LICENSE_ACCEPTED=true" > $__rsp_file_name
echo "USER_INSTALL_DIR=$__es_install_dir" >> $__rsp_file_name

./install.bin -i silent -f $__rsp_file_name

echo "Updating WEXCA... Done."

su - $__install_user_name -c "startccl.sh -bg" || true

if [[ "$INSTALL_TYPE" != "additional" ]] ; then
  
  #start server on master
  su - $__install_user_name -c "esadmin system start"
  
  echo ""

  echo "Access WEXCA server, if this is master node:"
  echo "  http://${__fqdn}:${__admin_http_port}/ESAdmin"
  echo "  User    : ${__install_user_name}" 
  echo "  Password: ${__install_user_password}" 

  echo ""
  echo "Access WEXCA search app:"
  echo "  http://${__fqdn}:${__search_http_port}/ui/search"
  echo ""
  echo "Access WEXCA analytics app:"
  echo "  http://${__fqdn}:${__search_http_port}/ui/analytics"
else

  echo "Use REST API or Admin GUI to add this node to WEXCA master"

fi


