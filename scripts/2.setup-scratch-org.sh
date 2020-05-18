export USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
echo setting up scratch org with USER_ALIAS = $USER_ALIAS
./create-scratch-org.sh
./set-password-scratch-org.sh
./display-scratch-org.sh > ../config/org-$USER_ALIAS.txt
./open-scratch-org.sh
echo create org wide email address in the scratch org and verify, then run "3.push-code.sh"