# Nextcloud: Einstellungen für alle User tätigen
# author: flo.alt@fa-netz.de
# ver: 0.8

#!/bin/bash

userconfirm () {	# interaktive Bestätigung durch den Benutzer
  read -p "Forfahren? [j/n] " confirm
  if [ -z $confirm ]; then
    userconfirm
  else
    if [[ $confirm =~ ^[jJ]{1}$ ]]; then
      echo "ok, es geht los..."; echo
    elif [[ $confirm =~ ^[nN]{1}$ ]]; then
      echo "dann halt nicht..."; echo
      exit 1
    else
      userconfirm
    fi
  fi
}

askforsetting() {
  echo
  read -p "Einstellung (z.B. core locale): " setkey
  read -p "Wert eingeben (z.B. de_DE): " setvalue
  if [ -z "$setkey" ] || [ -z "$setvalue" ]; then
    echo -e "\nBitte sowohl Einstellung als auch Wert angeben"
    askforsetting
  else
    echo; echo "Bei allen Usern wird die Einstellung \"$setkey\" mit dem Wert \"$setvalue\" konfiguriert."
  fi
}

makelist () {		# Benutzerliste in Array speichern
  sudo -u www-data php /var/www/nextcloud/occ user:list > usertemp
  array=$(sed -e 's/: .*//g' -e 's/  - //g' usertemp)
  rm usertemp
}

dothesetting () {
  for ncuser in $array; do
    sudo -u www-data php /var/www/nextcloud/occ user:setting $ncuser $setkey $setvalue
    echo "OK: $ncuser ---> $setkey = $setvalue"
  done
}

echo -e "\nHiermit wird eine Einstellung auf alle Nextcloud-User angewendet.\n"

askforsetting
userconfirm
makelist
dothesetting

exit 0
