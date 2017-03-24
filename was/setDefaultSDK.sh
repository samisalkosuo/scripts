#set default SDK to available SDK

cd $WAS_BIN_DIR

__sdk_name=$(./managesdk.sh -listAvailable | grep "SDK name" | awk '{print $4}')

./managesdk.sh -setCommandDefault -sdkname $__sdk_name
./managesdk.sh -setNewProfileDefault -sdkname $__sdk_name
./managesdk.sh -enableProfileAll -sdkname $__sdk_name -enableServers

#set SDK for custom node
./wsadmin.sh -user $WAS_ADMIN_USER -password $WAS_ADMIN_PASSWORD -c "AdminTask.setNodeDefaultSDK('[-nodeName CloudBurstNode-Custom_1 -sdkName $__sdk_name]');AdminConfig.save()"
