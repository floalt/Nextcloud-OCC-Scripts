# Nextcloud: neuen Benutzer anlegen
# author: flo.alt@fa-netz.de
# ver: 0.8
 
#!/bin/bash

var_apache_user=www-data
var_path_nextcloud=/var/www/nextcloud


askbasicinfos() {
  read -p "Benutzername: " ncuser
  read -p "Anzeige Name: " ncfullname
  read -p "Mailadresse: " ncmail
  if [ -z "$ncuser" ] || [ -z "$ncfullname" ] || [ -z "$ncmail" ]; then
    echo "Bitte alle Werte angeben"
    askbasicinfos
  fi
}

askpassword() {
  read -sp "Passwort: " pw1; echo
  if [ -z "$pw1" ]; then
    echo -e "\nLeere Passwörter sind nicht erlaubt!\n"
    askpassword
  else
    read -sp "Passwort wiederholen: " pw2; echo
    if [ "$pw1" != "$pw2" ]; then
      echo -e "\nDie Passwörter stimmen nicht überein\n"
      askpassword
    else
      export OC_PASS=$pw1
    fi
  fi
}

# Infos abfragen

echo -e "\nHiermit wird ein neuer Nextcloud Benutzer erstellt\n"
askbasicinfos
askpassword

# Benutzer hinzufügen

echo -e "\nDer Benutzer \"$ncfullname\" wird jetzt erstellt. Dazu sind sudo-Rechte nötig."

sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:add ${ncuser} --password-from-env --display-name="${ncfullname}"
sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:setting ${ncuser} settings email "${ncmail}"
sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:setting ${ncuser} core locale de_DE
sudo -E -u ${var_apache_user} php ${var_path_nextcloud}/occ user:setting ${ncuser} files quota 5G

exit 0