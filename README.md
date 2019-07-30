# occ-scripts: Nextcloud OCC Scripts

## newuser.sh

### description
Script zur Neuanlage eines Nextcloud-Benutzers. Hinterher muss man noch manuell die Gruppen für den User konfigurieren.

### usage
`./newuser.sh` (interactive)

### Feature request
- Gruppen noch mit einbauen

--------------------------------------

## groupallusers.sh

### description
Mit diesem Script kann man alle Benutzer auf einmal zu einer Gruppe hinzufügen oder daraus entfernen.

### usage
`./groupallusers.sh <add|remove> <groupname>`

### Feature Request
- Statt usertemp direkt in eine Variable schreiben

-------------------------------------

## setallusers.sh

### description
Mit diesem Script kann man Einstellungen für alle Benutzer auf einmal setzen.

### usage
`./setallusers.sh` (interactive)

### Feature Request
- Statt usertemp direkt in eine Variable schreiben
