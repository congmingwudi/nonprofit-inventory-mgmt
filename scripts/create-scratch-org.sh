USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
echo creating scratch org w/ USER_ALIAS = $USER_ALIAS
sfdx force:org:create -s -f ../config/project-scratch-def.json -a $USER_ALIAS