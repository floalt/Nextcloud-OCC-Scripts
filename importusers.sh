#!/bin/bash

### Import von Nextcloud-Usern aus einer csv-Datei
# author: flo.alt@fa-netz.de
# version: 0.8

var_now=$(date +"%Y%m%d-%H%M")
var_apache_user=www-data
var_path_nextcloud=/var/www/nextcloud

askinput () {
  read -p "Pfad: " input
  if [ -z "$input" ]; then
    echo -e "Hey, gib mal was ein!"
    askinput
  else
    if [ -f "$input" ]; then
      echo -e "\nOK: Datei "$input" wird verwendet.\n"
    else
      echo -e "\nFEHLER: Die Datei "$input" existiert nicht oder ist nicht lesbar.\n"
      askinput
    fi
  fi
}

askoutput () {
  read -p "Pfad: " outputpath
  if [ -z "$outputpath" ]; then
    echo -e "Hey, gib mal was ein!"
    askoutput
  else
    touch "$outputpath"/"writetest"
    if [ $? = 0 ]; then
      echo -e "\nOK: Liste wird in "$outputpath"/"$var_result_file" gespeichert.\n"
      rm "$outputpath"/"writetest"
      var_result_file="$outputpath"/"usercreate-$var_now"
    else
      echo -e "\nFEHLER: Die Datei "$outputpath"/"$var_result_file" kann nicht geschrieben werden\n"
      askoutput
    fi
  fi
}

## Benutzerabfragen

echo -e "\nBitte vollständigen Pfad zur csv-Datei angeben, die importiert werden soll."
echo -e "z.B. "/home/user/importusers.csv"\n"
askinput
echo -e "\nDie Kennwörter für die zu erstellenden Benutzer werden automatisch generiert und in einer txt-Datei gespeichert."
echo -e "Bitte hier den Pfad angeben, wo die Datei gespeichert werden soll."
echo -e "z.B. "/home/user"\n"
askoutput

## Importieren der csv-Datei
# Script übernommen und angepasst von https://help.nextcloud.com/t/importing-users-from-csv-file-and-adding-users-to-different-groups/30881/4 THANK YOU

echo -e "Es sind sudo-Rechte nötig!\n"
sudo echo ""

while read -r line
do
    echo "Rang: ${line}"
    var_password=$(pwgen 12 -nc 1)
    set -e
    export OC_PASS=$var_password
    # echo "${var_password} ${OC_PASS}"
    var_username=$(echo "${line}" | cut -d";" -f2)
    var_name=$(echo "${line}" | cut -d";" -f1)
    var_group1=$(echo "${line}" | cut -d";" -f3)
    var_group2=$(echo "${line}" | cut -d";" -f4)
    var_group3=$(echo "${line}" | cut -d";" -f5)
    var_group4=$(echo "${line}" | cut -d";" -f6)
    var_email=$(echo "${line}" | cut -d";" -f7)
    var_quota=$(echo "${line}" | cut -d";" -f8)
    if [ "${var_group4}" != "" ] ;then
        sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:add ${var_username} --password-from-env --group="${var_group1}" --group="${var_group2}" --group="${var_group3}" --group="${var_group4}" --display-name="${var_name}"
    elif [ "${var_group3}" != "" ] ;then
        sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:add ${var_username} --password-from-env --group="${var_group1}" --group="${var_group2}" --group="${var_group3}" --display-name="${var_name}"
    elif [ "${var_group2}" != "" ] ;then
        sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:add ${var_username} --password-from-env --group="${var_group1}" --group="${var_group2}" --display-name="${var_name}"
    elif [ "${var_group1}" != "" ] ;then
        sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:add ${var_username} --password-from-env --group="${var_group1}" --display-name="${var_name}"
    fi
    sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:setting ${var_username} settings email "${var_email}"
    if [ "${var_quota}" != "" ] ;then
    sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:setting ${var_username} files quota "${var_quota}"
    fi
    echo "${var_username};${var_password}" >> "${var_result_file}"
done < "$input"

# Abschluss

echo -e "\nDas Importieren wurde abgeschlossen."
echo -e "Hier ist die Datei mit den erstellten Benutzern und den generierten Kennwörtern:"
echo -e "$var_result_file\n"

exit 0
