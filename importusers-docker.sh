#!/bin/bash

### import Nextcloud user from csv-file for Nextcloud in Docker
# author: flo.alt@fa-netz.de
# version: 0.7

# run this script outside the docker container
# this script will then start user_add.sh inside the docker container
# make sure user_add.sh is in $var_path_docker/scripts
# and map this inside the docker container via docker-compose.yml like this: 
#    volumes:
#      (...)
#      - ./scripts:/usr/local/scripts



# setup: 

  var_path_docker="/mnt/data_ssd/docker-compose/nextcloud"

      # examples for user inputs
      # input="/home/itflows/import1.csv"
      # outputpath="/home/itflows"


## functions

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



# the action is starting right now:

  var_now=$(date +"%Y%m%d-%H%M")


  ## ask the user

    echo -e "\nBitte vollständigen Pfad zur csv-Datei angeben, die importiert werden soll."
    echo -e "z.B. "/home/user/importusers.csv"\n"
    askinput

    echo -e "\nDie Kennwörter für die zu erstellenden Benutzer werden automatisch generiert und in einer txt-Datei gespeichert."
    echo -e "Bitte hier den Pfad angeben, wo die Datei gespeichert werden soll."
    echo -e "z.B. "/home/user"\n"
    askoutput

  ## do the import within docker

    cp $input $var_path_docker/scripts/import.csv
    docker compose -f "$var_path_docker"/docker-compose.yml exec app /usr/local/scripts/user_add.sh

  ## move passwords.csv to $outputpath
    mv $var_path_docker/scripts/passwords.csv "$outputpath"/userlist_$var_now
  

  ## Abschluss
    rm $var_path_docker/scripts/import.csv
    echo -e "\nDas Importieren wurde abgeschlossen."
    echo -e "Hier ist die Datei mit den erstellten Benutzern und den generierten Kennwörtern:"
    echo -e "$outputpath/userlist_$var_now\n"