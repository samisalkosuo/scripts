function installJDK8 {

  local __jdkbinary=$1

  if [ ! -f $__jdkbinary ];
  then
    echo "Downloading JDK8..."
    local __jdkURL=$__jdkbinary
    curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k $__jdkURL
    __jdkbinary=$(echo "${__jdkURL##*/}")
  fi

  echo "Installing JDK8..."
  rpm -ivh $__jdkbinary
}