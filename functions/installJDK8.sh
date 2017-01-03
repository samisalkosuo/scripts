function installJDK8 {

  JDK8_URL="https://edelivery.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u112-linux-x64.tar.gz"

  curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k $JDK8_URL
  JDK8FILENAME=$(echo "${JDK8_URL##*/}")
  rpm -ivh $JDK8FILENAME
}