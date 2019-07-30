# Nextcloud: alle User zu einer Gruppe hinzufügen / entfernen
# author: flo.alt@fa-netz.de
# ver: 0.8

#!/bin/bash

action=$1
ncgroup=$2

printusage () {		# Hinweise zur Bedienung ausgeben
  echo; echo "Usage: $0 <add|remove> <groupname>"
  echo; echo add: fügt alle Nextcloud-User einer Nextcloud-Gruppe hinzu
  echo remove: entfernt alle Nextcloud-User aus einer Nextcloud-Gruppe; echo
  exit 1
}

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

makelist () {		# Benutzerliste in Array speichern
  sudo -u www-data php /var/www/nextcloud/occ user:list > usertemp
  array=$(sed -e 's/: .*//g' -e 's/  - //g' usertemp)
  rm usertemp
}

actionadd () {		# Action: group:adduser
  for ncuser in $array; do
    sudo -u www-data php /var/www/nextcloud/occ group:adduser $ncgroup $ncuser
    echo "OK: $ncuser ---> zu \"$ncgroup\" hinzugefügt"
  done
}

actionremove () {	# Action: group:removeuser
  for ncuser in $array; do
    sudo -u www-data php /var/www/nextcloud/occ group:removeuser $ncgroup $ncuser
    echo "OK: $ncuser ---> aus \"$ncgroup\" entfernt"
  done
}


if [ -z $2 ]; then	# Prüfen, ob $2 (ncgroup) gesetzt
  printusage
  exit 1
else
  if [ $1 = "add" ]; then	# $1 (action) ist ADD
    echo; echo "Alle Nextcloud-Benutzer werden der Gruppe \"$ncgroup\" hinzugefügt."; echo
    userconfirm
    makelist
    actionadd
  elif [ $1 = "remove" ]; then	# $1 (action) ist REMOVE
    echo; echo "Alle Nextcloud-Benutzer werden aus der Gruppe \"$ncgroup\" entfernt."; echo
    userconfirm
    makelist
    actionremove
  else				# $1 (action) ist falsch
    printusage
  fi
fi

exit 0
