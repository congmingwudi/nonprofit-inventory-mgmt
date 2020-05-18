USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
echo displaying scratch org w/ USER_ALIAS = $USER_ALIAS
sfdx force:user:display -u $USER_ALIAS