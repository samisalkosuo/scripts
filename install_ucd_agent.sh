#!/usr/bin/env bash
#
#install_ucd_agent.sh - Install UrbanCode Deploy agent
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
#
#
#Uses hints and code from Bash3 Boilerplate. Copyright (c) 2014, kvz.io
#http://kvz.io/blog/2013/11/21/bash-best-practices/
#and
#https://github.com/kvz/bash3boilerplate

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

#START clpargs config
source $__dir/clpargs/clpargs.bash 2> /dev/null
if [ $? -eq 0 ]; then

  #script description
  clpargs_program_description "Installs UrbanCode Deploy agent"

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]

  #for example:
  clpargs_define UCD_HOST "hostname" "Hostname or IP to UCD server." true
  clpargs_define UCD_ADMIN_USERNAME "ucduser" "Admin username." false "admin"
  clpargs_define UCD_ADMIN_PASSWORD "pwd" "Admin password." false "passw0rd"
  clpargs_define AGENT_INSTALL_DIR "str" "Agent install dir." true
  clpargs_define AGENT_NAME "str" "Agent name." true

  #parse arguments
  clpargs_parse "$@"

else
  #if clpargs is not used, you can set environment variables here.
  #or elsewhere.
  echo "ERROR: clpargs.bash missing"
  exit 1

fi
#END clpargs config

#START set options
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace
#END set options

__currentDir=$(pwd)

#source all functions
cd $__dir/functions;for f in *; do [[ -f "$f" ]] && source "$f"; done;cd $__currentDir

#ADD YOUR SCRIPT HERE (AND BELOW)
__user=root
__group=root

echo "Installing UCD agent..."
__agent_url=https://$UCD_HOST:8443/tools/ibm-ucd-agent.zip

wget --no-check-certificate $__agent_url

__agent_file=$(echo "${__agent_url##*/}")
unzip -q $__agent_file

cd ibm-ucd-agent-install
__props_file=agent.install.properties 
cp example.agent.install.properties $__props_file

changeString $__props_file "#IBM UrbanCode Deploy/java.home=" "IBM UrbanCode Deploy/java.home=/usr/java/latest" 
changeString $__props_file "locked/agent.jms.remote.host=localhost" "locked/agent.jms.remote.host=$UCD_HOST" 
changeString $__props_file "#server.url=" "server.url=https://$UCD_HOST:8443"
changeString $__props_file "locked/agent.name=ibm-ucdagent" "locked/agent.name=$AGENT_NAME"
changeString $__props_file "locked/agent.home=/opt/urbancode/ibm-ucdagent" "locked/agent.home=$AGENT_INSTALL_DIR"

./install-agent-from-file.sh $__props_file

cp $AGENT_INSTALL_DIR/bin/init/agent  $AGENT_INSTALL_DIR/bin/init/agent.original
changeString $AGENT_INSTALL_DIR/bin/init/agent "AGENT_USER=" "AGENT_USER=$__user"
changeString $AGENT_INSTALL_DIR/bin/init/agent "AGENT_GROUP=" "AGENT_GROUP=$__group"
mv $AGENT_INSTALL_DIR/bin/init/agent $AGENT_INSTALL_DIR/bin/init/$AGENT_NAME

chmod 755 $AGENT_INSTALL_DIR/bin/init/$AGENT_NAME

cp $AGENT_INSTALL_DIR/bin/init/$AGENT_NAME /etc/rc.d/init.d/
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc5.d/S98$AGENT_NAME
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc4.d/S98$AGENT_NAME
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc3.d/S98$AGENT_NAME

chkconfig --add $AGENT_NAME
chkconfig $AGENT_NAME on

service $AGENT_NAME start
