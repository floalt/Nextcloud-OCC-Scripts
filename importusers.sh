#!/bin/bash
var_datum=$(date +"%Y%m%d")
input="ncusers.csv"
var_apache_user=www-data
var_path_nextcloud=/var/www/nextcloud
var_result_file="${var_datum}_user_create.txt"

while read -r line
do
    echo "Rang: ${line}"
    var_password=$(pwgen 12 -nc 1)
    set -e
    export OC_PASS=$var_password
    echo "${var_password} ${OC_PASS}"
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
exit 0
