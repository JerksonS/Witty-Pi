#!/bin/bash
# file: installWittyPi.sh
#
# This script will install required software for Witty Pi.
# It is recommended to run it in your home directory.
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/wittyPi"

echo '================================================================================'
echo '|                                                                              |'
echo '|                   Witty Pi Software Installing Script                        |'
echo '|                                                                              |'
echo '================================================================================'

# enable I2C on Raspberry Pi
echo '>>> Enable I2C'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q 'i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q 'dtparam=i2c1=on' /boot/config.txt; then
  echo 'Seems i2c1 parameter already set, skip this step.'
else
  echo 'dtparam=i2c1=on' >> /boot/config.txt
fi
if grep -q 'dtparam=i2c_arm=on' /boot/config.txt; then
  echo 'Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi
if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then
  sed -i 's/^blacklist spi-bcm2708/#blacklist spi-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
  sed -i 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
else
  echo 'File raspi-blacklist.conf does not exist, skip this step.'
fi

# install i2c-tools
echo '>>> Install i2c-tools'
if hash i2cget 2>/dev/null; then
  echo 'Seems i2c-tools is installed already, skip this step.'
else
  apt-get install -y i2c-tools
fi

# install wiringPi
echo '>>> Install wiringPi'
if hash gpio 2>/dev/null; then
  echo 'Seems wiringPi is installed already, skip this step.'
else
  git clone git://git.drogon.net/wiringPi
  cd wiringPi
  ./build
  cd ..
fi

# install wittyPi
echo '>>> Install wittyPi'
if [ -f wittyPi ]; then
  echo 'Seems wittyPi is installed already, skip this step.'
else
  wget http://www.uugear.com/repo/WittyPi/LATEST -O wittyPi.zip
  unzip wittyPi.zip -d wittyPi
  cd wittyPi
  chmod +x wittyPi.sh
  chmod +x daemon.sh
  chmod +x syncTime.sh
  chmod +x runScript.sh
  sed  -e "s#/home/pi/wittyPi#$DIR#g" init.sh >/etc/init.d/wittypi
  chmod +x /etc/init.d/wittypi
  update-rc.d wittypi defaults
  cd ..
  sleep 2
  rm wittyPi.zip
fi

echo
echo '>>> All done. Please reboot your Pi :-)'
