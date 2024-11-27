#!/bin/bash

# description: Get users (and some infos about them)
#   from Nextcloud API via http
#   saving to xml file
# author: flo.alt@it-flows.de
# version: 0.5


# Nextcloud API URL und Administrator-Anmeldeinformationen
NEXTCLOUD_URL="https://nextcloud.domain.de/ocs/v1.php/cloud/users"
ADMINNAME="nextadmin"
PASSWORD="myverysecretpasswort"

# Datei zum Speichern der Ergebnisse
OUTPUT_FILE="user_details.xml"

# API-Anfrage für die Liste der Benutzernamen
response=$(curl -u "$ADMINNAME:$PASSWORD" -X GET "$NEXTCLOUD_URL" -H "OCS-APIRequest: true")

# Überprüfen, ob die API-Antwort erfolgreich war
status=$(echo "$response" | grep -oP '<status>\K[^<]+')

if [[ "$status" == "ok" ]]; then
    # Extrahiere Benutzernamen aus der XML-Antwort
    usernames=$(echo "$response" | grep -oP '<element>\K[^<]+')

    # Schleife für jeden Benutzernamen
    for username in $usernames; do
        # API-Anfrage für die Details eines bestimmten Benutzers
        details_response=$(curl -u "$ADMINNAME:$PASSWORD" -X GET "$NEXTCLOUD_URL/$username" -H "OCS-APIRequest: true")

        # Schreibe die Details des Benutzers in die Ausgabedatei
        echo "Details für Benutzer: $username" >> "$OUTPUT_FILE"
        echo "$details_response" >> "$OUTPUT_FILE"
        echo "-------------------------------------------------------" >> "$OUTPUT_FILE"
    done

    echo "Ergebnisse wurden in die Datei $OUTPUT_FILE gespeichert."
else
    echo "Fehler bei der Abfrage der Benutzerliste."
    echo "API-Antwort:"
    echo "$response"
fi
