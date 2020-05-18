USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
# perm set 1
PERM_SET=Inventory_Mgmt
echo assigning permission set $PERM_SET to USER_ALIAS = $USER_ALIAS
sfdx force:user:permset:assign -n $PERM_SET -u $USER_ALIAS