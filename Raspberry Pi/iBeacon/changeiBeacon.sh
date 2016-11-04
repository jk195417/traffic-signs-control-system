#!/bin/sh
. /home/pi/ibeacon/ibeacon.conf
SIGNAL=$MINOR
if [[ "$1" == "R" ]]; then
  SIGNAL="00 01"
elif [[ "$1" == "Y" ]]; then
  SIGNAL="00 02"
elif [[ "$1" == "G" ]]; then
  SIGNAL="00 03"
fi

echo
echo "更改iBeacon廣播內容中..."
sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 $UUID_FCU $MAJOR $SIGNAL $POWER 00
echo "完成"