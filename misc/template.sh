#!/usr/bin/env bash
#
#template.sh - Template for bash scripts. Use as starting point of your script, change name and description.
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
__clpargs_file=$__dir/clpargs/clpargs.bash
if [ ! -f $__clpargs_file ];
then
  #clpargs.bash not found in subdirectory
  #try one dir above
  __clpargs_file=$__dir/../clpargs/clpargs.bash
fi

source $__dir/clpargs/clpargs.bash 2> /dev/null
if [ $? -eq 0 ]; then

  #script description
  clpargs_program_description "SCRIPT DESCRIPTION HERE"

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]

  #for example:
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
