#change occurrences of string in file
function changeString {
	if [[ $# -ne 3 ]]; then
    	echo "$FUNCNAME ERROR: Wrong number of arguments. Requires FILE FROMSTRING TOSTRING."
    	return 1
	fi

	local SED_FILE=$1
	local FROMSTRING=$2
	local TOSTRING=$3
	local TMPFILE=$SED_FILE.tmp

	#get file owner and permissions
	local USER=$(stat -c %U $SED_FILE)
	local GROUP=$(stat -c %G $SED_FILE)
	local PERMISSIONS=$(stat -c %a $SED_FILE)

	#escape to and from strings
	FROMSTRINGESC=$(echo $FROMSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	TOSTRINGESC=$(echo $TOSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

	sed -e "s/$FROMSTRINGESC/$TOSTRINGESC/g" $SED_FILE  > $TMPFILE && mv $TMPFILE $SED_FILE

  #set original owner and permissions
	chown $USER:$GROUP $SED_FILE
	chmod $PERMISSIONS $SED_FILE
	if [ ! -f $TMPFILE ]; then
	    return 0
 	else
	 	echo "$FUNCNAME ERROR: Something went wrong."
	 	return 2
	fi
}
