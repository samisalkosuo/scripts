function installJDK8 {

  JDK8_URL="https://edelivery.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.rpm"

  curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k $JDK8_URL
  JDK8FILENAME=$(echo "${JDK8_URL##*/}")
  rpm -ivh $JDK8FILENAME
}