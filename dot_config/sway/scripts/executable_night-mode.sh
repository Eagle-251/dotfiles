#!/bin/sh

defaultSunset() {
  wlsunset -l 50.8 -l 4.3
}


# network=$($DOTFILES_ROOT/scripts/check-network.sh)

checkNetwork() {
  for interface in $(ls /sys/class/net/ | grep -v lo);
  do
    if [[ $(cat /sys/class/net/$interface/carrier) = 1 ]]; then OnLine=1; fi
  done
  if ! [ $OnLine ] 
  	then echo "0"
  	else echo "1"
  fi
}

if [ "$(checkNetwork)" = "1" ]
then
  CONTENT=$(curl -s https://freegeoip.app/json/)
  longitude=$(echo $CONTENT | jq .longitude)
  latitude=$(echo $CONTENT | jq .latitude)
  if [ -z $longitude ] || [ -z $latitude ]
  then
    wlsunset -l $latitude -L $longitude
  else defaultSunset
  fi
else
  defaultSunset
fi
