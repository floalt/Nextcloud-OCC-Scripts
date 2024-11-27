#!/bin/bash

### import Nextcloud user from csv-file for Nextcloud in Docker
# runs inside the docker-container (app) and is started by importusers-docker.sh (occ-scripts)
# author: flo.alt@fa-netz.de
# version: 0.7

# make sure user_add.sh is in $var_path_docker/scripts
# and map this inside the docker container via docker-compose.yml like this: 
#    volumes:
#      (...)
#      - ./scripts:/usr/local/scripts


input="/usr/local/scripts/import.csv"
password_file="/usr/local/scripts/passwords.csv"
wwwroot="/var/www/html"
    


# Funktion zur Generierung eines zufälligen Strings
generate_random_string() {
    local length=16
    local num_upper=2
    local num_special=2
    local num_digits=2
    local num_lower=$((length - num_upper - num_special - num_digits))

    # Zeichensätze
    local upper_chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local special_chars="@#-_=+?"
    local digits="0123456789"
    local lower_chars="abcdefghijklmnopqrstuvwxyz"

    # Zufällige Auswahl von Zeichen
    local random_upper=$(tr -dc "$upper_chars" </dev/urandom | head -c "$num_upper")
    local random_special=$(tr -dc "$special_chars" </dev/urandom | head -c "$num_special")
    local random_digits=$(tr -dc "$digits" </dev/urandom | head -c "$num_digits")
    local random_lower=$(tr -dc "$lower_chars" </dev/urandom | head -c "$num_lower")

    # Kombinieren der zufälligen Teile
    local combined="$random_upper$random_special$random_digits$random_lower"

    # Mischen der Zeichen
    echo "$combined" | fold -w1 | shuf | tr -d '\n'
}


# CSV-Datei zeilenweise lesen

while IFS=';' read -r var_name var_username var_group1 var_group2 var_group3 var_group4 var_email var_quota
do
    echo "Name: ${var_name}, Benutzer: ${var_username}, Gruppen: ${var_group1}, ${var_group2}, ${var_group3}, ${var_group4}, Email: ${var_email}, Quota: ${var_quota}"

    # Generieren und Setzen des Passworts
    var_password=$(generate_random_string)
    export OC_PASS="${var_password}"

    # Docker Compose Befehl ausführen
    if [ -n "${var_group4}" ]; then
        php $wwwroot/occ user:add "${var_username}" --password-from-env --group="${var_group1}" --group="${var_group2}" --group="${var_group3}" --group="${var_group4}" --display-name="${var_name}"
    elif [ -n "${var_group3}" ]; then
        php $wwwroot/occ user:add "${var_username}" --password-from-env --group="${var_group1}" --group="${var_group2}" --group="${var_group3}" --display-name="${var_name}"
    elif [ -n "${var_group2}" ]; then
        php $wwwroot/occ user:add "${var_username}" --password-from-env --group="${var_group1}" --group="${var_group2}" --display-name="${var_name}"
    elif [ -n "${var_group1}" ]; then
        php $wwwroot/occ user:add "${var_username}" --password-from-env --group="${var_group1}" --display-name="${var_name}"
    fi

    # Benutzer-Einstellungen setzen
    php $wwwroot/occ user:setting "${var_username}" settings email "${var_email}"
    if [ -n "${var_quota}" ]; then
        php $wwwroot/occ user:setting "${var_username}" files quota "${var_quota}"
    fi

    # Ergebnis in die Datei schreiben
    echo "${var_username};${var_password}" >> "${password_file}"

done < "$input"

exit 0
