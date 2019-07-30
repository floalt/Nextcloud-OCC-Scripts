# occ-scripts: Nextcloud OCC Scripts

## groupallusers.sh

### description
Add all users to a group or remove them out of a group.
Took a lot of code from https://help.nextcloud.com/t/importing-users-from-csv-file-and-adding-users-to-different-groups/30881/4
Thanks to Troublicious

### usage
`./groupallusers.sh <add|remove> <groupname>`

### feature Request
- script uses temporary file: usertemp. would be better to use a variable

----

## importusers.sh

### description
Import users from a csv-file. Passwords are generated automatically and stored in a output txt-file.

### usage
`./importusers.sh` (interactive)

### feature request
- 


----

## newuser.sh

### description
Add a new user in a quick and interactive way. After creating the user you have to manually assign to Groups.
Would be better to do this in the script => feature request.

### usage
`./newuser.sh` (interactive)

### feature request
- get the groups into the script

----

## setallusers.sh

### description
Do settings for all users with one hit.

### usage
`./setallusers.sh` (interactive)

### feature Request
- script uses temporary file: usertemp. would be better to use a variable
