#!/bin/bash

# description: resets passwort for all Nextcloud users
#   using Nextcloud API via http
#   all users get the same new password
#   yes, there are some usecases for that ;-)
# author: flo.alt@it-flows.de
# version: 0.5


# Nextcloud API URL und Administrator-Anmeldeinformationen
NEXTCLOUD_URL="https://nextcloud.domain.de/ocs/v1.php/cloud/users"
ADMINNAME="nextadmin"
PASSWORD="myverysecretpasswort"

# Neues Kennwort für alle Benutzer
NEW_PASSWORD="MyNewCoolSecret4all"




# Countdown-Funktion für die Pause
countdown() {

  dauer=$1

  while [ $dauer -gt 0 ]; do
    minuten=$((dauer / 60))
    sekunden=$((dauer % 60))
    printf "\r%02d:%02d" $minuten $sekunden
    sleep 1  # eine Sekunde warten
    dauer=$((dauer - 1)) # Dauer um 1 Sekunde verringern
  done

  echo    # Zeilenumbruch am Ende
}


# Nach 40 Anfragen machen wir eine Pause, sonst macht die API dicht
PAUSE=600

# API-Anfrage für die Liste der Benutzernamen
response=$(curl -s -u "$ADMINNAME:$PASSWORD" -X GET "$NEXTCLOUD_URL" -H "OCS-APIRequest: true")

# Überprüfen, ob die API-Antwort erfolgreich war
status=$(echo "$response" | grep -oP '<status>\K[^<]+')

if [[ "$status" == "ok" ]]; then
    # Extrahiere Benutzernamen aus der XML-Antwort
    usernames=$(echo "$response" | grep -oP '<element>\K[^<]+')

    # Schleife für jeden Benutzernamen
    count=0
    for username in $usernames; do
        if [[ "$username" == "$ADMINNAME" ]]; then
            echo "Überspringe Benutzer $username."
        else
            # API-Anfrage zum Zurücksetzen des Kennworts eines bestimmten Benutzers
            password_reset_response=$(curl -s -u "$ADMINNAME:$PASSWORD" -X PUT "$NEXTCLOUD_URL/$username" -H "OCS-APIRequest: true" -d "key=password&value=$NEW_PASSWORD")

            # Überprüfen, ob die Kennwortänderung erfolgreich war
            reset_status=$(echo "$password_reset_response" | grep -oP '<status>\K[^<]+')
            if [[ "$reset_status" == "ok" ]]; then
                echo "Kennwort für Benutzer $username erfolgreich zurückgesetzt."
            else
                echo "Fehler beim Zurücksetzen des Kennworts für Benutzer $username."
                echo "API-Antwort:"
                echo "$password_reset_response"
            fi
        fi

        # Erhöhe den Zähler und prüfe, ob eine Pause eingelegt werden muss
        ((count++))
        if (( count % 40 == 0 )); then
            echo "40 Benutzer bearbeitet. kurze Pause..."
            countdown $PAUSE
        fi
    done

    echo "Alle Kennwörter wurden erfolgreich zurückgesetzt."
else
    echo "Fehler bei der Abfrage der Benutzerliste."
    echo "API-Antwort:"
    echo "$response"
fi
