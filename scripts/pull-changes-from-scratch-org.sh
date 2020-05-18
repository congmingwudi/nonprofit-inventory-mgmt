USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
echo pull changes from scratch org USER_ALIAS = $USER_ALIAS
# pull with -f (force overwrite) option
sfdx force:source:pull -f -u $USER_ALIAS