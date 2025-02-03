#!/bin/bash

# Konvertiert die Ausgabe von getusers.sh in eine importierbare Textdatei
# author: flo.alt@fa-netz.de
# ver: 0.5




# Überprüfen, ob eine Datei als Argument übergeben wurde
if [ $# -ne 1 ]; then
    echo "Benutzung: $0 <datei.xml>"
    exit 1
fi

# Datei als Argument speichern
datei="$1"

# Überprüfen, ob die Datei existiert
if [ ! -f "$datei" ]; then
    echo "Datei '$datei' existiert nicht."
    exit 1
fi

# CSV-Datei erstellen und Header schreiben
csv_datei="${datei%.xml}.csv"  # Ersetze .xml mit .csv für den Dateinamen
echo "Displayname;Username;Group1;Group2;Group3;Group4;Email;Quota" > "$csv_datei"

# Variablen initialisieren für Benutzerkonto-Daten
displayname=""
username=""
email=""
group1=""
group2=""
group3=""
group4=""

# Funktion zur Verarbeitung der aktuellen Benutzerkonto-Daten
verarbeite_benutzerkonto() {
    echo "$displayname;$username;$group1;$group2;$group3;$group4;$email;;" >> "$csv_datei"
    # Variablen zurücksetzen für das nächste Benutzerkonto
    displayname=""
    username=""
    email=""
    group1=""
    group2=""
    group3=""
    group4=""
}

# Durch die XML-Datei iterieren und Daten extrahieren
while IFS= read -r line; do
    # Zeile, die die horizontale Linie darstellt, ignoriert werden
    pattern="^-+$"
    if [[ "$line" =~ $pattern ]]; then
        # Verarbeite die bisher gesammelten Daten für das vorherige Benutzerkonto
        if [ -n "$displayname" ]; then
            verarbeite_benutzerkonto
        fi
    fi

    # Displayname extrahieren
    pattern="<displayname>(.*?)</displayname>"
    if [[ "$line" =~ $pattern ]]; then
        displayname="${BASH_REMATCH[1]}"
    fi

    # Username extrahieren
    pattern="<id>(.*?)</id>"
    if [[ "$line" =~ $pattern ]]; then
        username="${BASH_REMATCH[1]}"
    fi

    # Email extrahieren
    pattern="<email>(.*?)</email>"
    if [[ "$line" =~ $pattern ]]; then
        email="${BASH_REMATCH[1]}"
    fi

    # Gruppen extrahieren (bis zu 4 Gruppen)
    pattern="<groups>"
    if [[ "$line" =~ $pattern ]]; then
        group_count=0
        while IFS= read -r inner_line; do
            
            # Beende die innere Schleife, wenn das Ende des <groups>-Blocks erreicht ist
            endofgroups="</groups>"
            if [[ "$inner_line" =~ $endofgroups ]]; then
                break
            fi
            
            
            inner_pattern="<element>(.*)</element>"
            if [[ "$inner_line" =~ $inner_pattern ]]; then
                group_count=$((group_count + 1))
                group="group$group_count"
                eval "$group=\"${BASH_REMATCH[1]}\""
            fi
        done
        # Fehlende Gruppen mit Leerzeichen auffüllen, falls weniger als 4
        for ((i = group_count + 1; i <= 4; i++)); do
            group="group$i"
            eval "$group=''"
        done
    fi



done < "$datei"

# Verarbeite die letzten gesammelten Daten für das letzte Benutzerkonto
if [ -n "$displayname" ]; then
    verarbeite_benutzerkonto
fi

echo "CSV-Datei '$csv_datei' wurde erstellt."
