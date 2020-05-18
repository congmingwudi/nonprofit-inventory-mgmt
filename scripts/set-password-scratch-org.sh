USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
echo generating password for scratch org w/ USER_ALIAS = $USER_ALIAS
sfdx force:user:password:generate -u $USER_ALIAS --json