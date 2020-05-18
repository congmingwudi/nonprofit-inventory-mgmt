export USER_ALIAS="${USER_ALIAS:-Nonprofit_Scratch}"
./push-changes-to-scratch-org.sh
./assign-perm-set-to-user.sh
cd data
./import-sample-data.sh
cd ..
./open-scratch-org.sh