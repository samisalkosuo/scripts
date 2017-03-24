#restore WAS config that was taken using backupConfig.sh
#in this directory


echo "Running $WAS_BIN_DIR/restoreConfig.sh using default user/password"

cd $WAS_BIN_DIR

./restoreConfig.sh ~/was_backup.zip -nostop -user $WAS_ADMIN_USER -password $WAS_ADMIN_PASSWORD

