#!/usr/bin/env bash
#
#template.sh - Template for bash scripts. Copy ths to your script, change name and description.
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

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

#========================================================================
#clpargs config
source $__dir/clpargs/clpargs.bash 2> /dev/null
if [ $? -eq 0 ]; then

  #script description
  clpargs_program_description "Install UCD Server."

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]
  clpargs_define UCDSERVER_BINARY_URL "url" "URL to UCD binary file." true
  clpargs_define INSTALL_JDK8 "bool" "Install JDK8: true/false." false "true"
  clpargs_define UCD_SERVER_ADMIN_PASSWORD "pwd" "Admin password." false "passw0rd"
  clpargs_define AGENT_NAME "str" "Agent name." false "default-ucd-agent"

  #parse arguments
  clpargs_parse "$@"

else
  #if clpargs is not used, you can set environment variables here.
  #or elsewhere.
  echo "ERROR: clpargs.bash missing"
  exit 1

fi
#========================================================================

#START set options
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace
#END set options

CURRENTDIR=$(pwd)
#source all functions
cd $__dir/functions;for f in *; do [[ -f "$f" ]] && source "$f"; done;cd $CURRENTDIR

echo "Installing UCD..."

if [[ "$INSTALL_JDK8" == "true" ]] ; then
  installJDK8
fi

echo "Downloading UCD binaries..."

wget $UCDSERVER_BINARY_URL

echo "Extracting UCD binary..."
unzip -q *.zip
echo "Extracting UCD binary... done."

echo "Move ucd install dir under /...."
mv ibm-ucd-install /

INSTALL_DIR=/ibm-ucd-install
cd $INSTALL_DIR

#modify install properties file
INSTALL_PROPS=install.properties

PASSWORD=$UCD_SERVER_ADMIN_PASSWORD

echo nonInteractive=true >> $INSTALL_PROPS
echo server.initial.password=$PASSWORD >> $INSTALL_PROPS
echo hibernate.connection.password=$PASSWORD >> $INSTALL_PROPS
echo install.java.home=/usr/java/latest >> $INSTALL_PROPS

#installer asks for whether to upgrade and java home
./install-server.sh <<!

/usr/java/latest
!

echo "UCD server installed."

echo "Setting auto start..."
#as instructed in http://www.ibm.com/support/knowledgecenter/en/SS4GSP_6.2.1/com.ibm.udeploy.install.doc/topics/run_server.html

chmod ugo+x /etc/rc.d/init.d/functions

SVC_FILE=/opt/ibm-ucd/server/bin/init/server

changeString $SVC_FILE @SERVER_USER@ root
changeString $SVC_FILE @SERVER_GROUP@ root

#change flags after changing the file, above commands create new file and resets flags
chmod 755 $SVC_FILE

cd /etc/init.d
ln -s /opt/ibm-ucd/server/bin/init/server ucdserver

chkconfig --add ucdserver
chkconfig ucdserver on
service ucdserver start

echo "UCD server started."

echo "Installing UCD agent..."

USER=root
GROUP=root

UCD_SERVER_IP=$(hostname -f)

echo "Downloading UCD agent..."
AGENTURL=https://$UCD_SERVER_IP:8443/tools/ibm-ucd-agent.zip
CMD="wget --no-check-certificate $AGENTURL"
#try to download 15 times before giving up
n=0
until [ $n -ge 15 ]
do
   $CMD && break
   echo "Download failed.. trying again..."
   n=$[$n+1]
   sleep 20
done

AGENTFILE=$(echo "${AGENTURL##*/}")
unzip -q $AGENTFILE

AGENTDIR=/opt/urbancode/$AGENT_NAME

cd ibm-ucd-agent-install
PROPSFILE=agent.install.properties
cp example.agent.install.properties $PROPSFILE

changeString $PROPSFILE "#IBM UrbanCode Deploy/java.home=" "IBM UrbanCode Deploy/java.home=/usr/java/latest"
changeString $PROPSFILE "locked/agent.jms.remote.host=localhost" "locked/agent.jms.remote.host=$UCD_SERVER_IP"
changeString $PROPSFILE "#server.url=" "server.url=https://$UCD_SERVER_IP:8443"
changeString $PROPSFILE "locked/agent.name=ibm-ucdagent" "locked/agent.name=$AGENT_NAME"
changeString $PROPSFILE "locked/agent.home=/opt/urbancode/ibm-ucdagent" "locked/agent.home=$AGENTDIR"

./install-agent-from-file.sh $PROPSFILE

cp $AGENTDIR/bin/init/agent  $AGENTDIR/bin/init/agent.original
changeString $AGENTDIR/bin/init/agent "AGENT_USER=" "AGENT_USER=$USER"
changeString $AGENTDIR/bin/init/agent "AGENT_GROUP=" "AGENT_GROUP=$GROUP"
mv $AGENTDIR/bin/init/agent $AGENTDIR/bin/init/$AGENT_NAME

chmod 755 $AGENTDIR/bin/init/$AGENT_NAME

cp $AGENTDIR/bin/init/$AGENT_NAME /etc/rc.d/init.d/
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc5.d/S98$AGENT_NAME
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc4.d/S98$AGENT_NAME
ln -s /etc/rc.d/init.d/$AGENT_NAME /etc/rc.d/rc3.d/S98$AGENT_NAME

chkconfig --add $AGENT_NAME
chkconfig $AGENT_NAME on

service $AGENT_NAME start

#install UCD CLI toolkit
#sleep a while so that UCD server is started
sleep 30

UCD_SERVER_URL="https://$UCD_SERVER_IP:8443"
CMD="wget --no-check-certificate $UCD_SERVER_URL/tools/udclient.zip"
#try to download 5 times before giving up
n=0
until [ $n -ge 5 ]
do
   $CMD && break
   echo "Download failed.. trying again..."
   n=$[$n+1]
   sleep 15
done

unzip udclient.zip

UDCLIENT_DIR=/udclient

mv udclient $UDCLIENT_DIR

EXECUTE_DEFAULT_UCD_CONFIG=true
if [[ "$EXECUTE_DEFAULT_UCD_CONFIG" == "true" ]] ; then
  #sleep a while so that agent is available
  sleep 30

  #add default agent
  UCD_ADMIN_USER=admin
  UCD_ADMIN_PASSWORD=$UCD_SERVER_ADMIN_PASSWORD
  UCD_DEFAULT_AGENT_NAME=$AGENT_NAME
  FILE=json.txt
  echo "{" > $FILE
  echo "\"artifactAgent\" : \"$UCD_DEFAULT_AGENT_NAME\"" >>  $FILE
  echo "}" >> $FILE
  $UDCLIENT_DIR/udclient -username $UCD_ADMIN_USER -password $UCD_ADMIN_PASSWORD -weburl $UCD_SERVER_URL setSystemConfiguration $FILE
fi

echo "UCD Server installed."
echo "UCD URL: https://$UCD_SERVER_IP:8443/"
echo "UCD admin user name is \"admin\""
