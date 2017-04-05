#!/usr/bin/env bash
#
#setup_bluemix_cli.sh - Installs Cloud Foundry, Kubernetes and IBM Bluemix CLI tools.
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
  clpargs_program_description "Installs Bluemix and Cloud Foundry CLI tools for RHEL Linux."

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]

  clpargs_define OS_TYPE "ostype" "OS type: rhel, ubuntu or mac." false "rhel"
  clpargs_define BLUEMIX_CLI_URL "url" "URL of Bluemix CLI tool install file." false "http://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/Bluemix_CLI_0.5.1_amd64.tar.gz"
  clpargs_define KUBERNETES_CLI_URL "url" "URL of Linux Kubernetes CLI tool." false "http://storage.googleapis.com/kubernetes-release/release/v1.5.3/bin/linux/amd64/kubectl"

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
#cd $__dir/functions;for f in *; do [[ -f "$f" ]] && source "$f"; done;cd $__currentDir

#ADD YOUR SCRIPT HERE (AND BELOW)

wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo

yum -y install cf-cli

#install docker
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine
systemctl enable docker.service
systemctl start docker

#Instal Kubernetes CLI
wget $KUBERNETES_CLI_URL
__kubectl_file=$(echo "${KUBERNETES_CLI_URL##*/}")
chmod 755 $__kubectl_file
mv $__kubectl_file /usr/local/bin

# Installing Bluemix CLI...
#from http://clis.ng.bluemix.net/ui/home.html

wget $BLUEMIX_CLI_URL
__bluemix_cli_file=$(echo "${BLUEMIX_CLI_URL##*/}")

tar -xvf $__bluemix_cli_file
cd Bluemix_CLI
./install_bluemix_cli
cd ..
#rm -rf Bluemix_CLI

#setting up plugins for Bluemix containers
bx plugin install container-registry -r Bluemix
bx plugin install container-service -r Bluemix

echo ""
echo "Docker version:"
docker -v
echo ""

echo ""
echo "Kubernetes CLI version:"
kubectl version
echo ""

echo "CF version:"
cf -v
echo ""

echo "BX version:"
bx -v
