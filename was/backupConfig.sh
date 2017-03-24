#backup WAS config


echo "Running $WAS_BIN_DIR/backupConfig.sh using default user/password"

cd $WAS_BIN_DIR

./backupConfig.sh ~/was_backup.zip -nostop -user $WAS_ADMIN_USER -password $WAS_ADMIN_PASSWORD

