#!/usr/bin/env bash
#
#uninstall_wexca.sh - Unnstall WEXCA from current system
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
  clpargs_program_description "Uninstall WEXCA Server."

  #define arguments to use (optional)
  #syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]
  clpargs_define DELETE_DATA_DIR "true or false" "Delete data directory." true
  clpargs_define VERSION "WEXCA version" "Delete data directory." true "11.0.2.0"
  
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
source env.sh

__rsp_file=${__currentDir}/rsp_uninstall.properties
echo "DELETE_DATA_DIRECTORY=${DELETE_DATA_DIR}" > $__rsp_file

cd $__es_install_dir/uninstall_${VERSION}

su - $__install_user_name -c "esadmin system stop" || true

echo "Uninstalling WEXCA ${VERSION}..."
./uninstall_${VERSION} -i silent -f $__rsp_file
echo "Uninstalling WEXCA ${VERSION}... Done."