
# This script dumps a log from FM radio: frequency & RDS (PI, PS, RT) and shows a toast message with PI code when it has changed.
# It is necessary to have toast application installed from here:
# http://forum.xda-developers.com/showpost.php?p=7995004&postcount=2
# I use version without a drawer icon.
# Don't worry, this app seem to be safe (but you have to enable installing form unknown sources to install it): 
# https://www.virustotal.com/pl/file/0927571c9bdd4475213fa15cbff900c0c394c4296819318031ddc158badb5448/analysis/
# https://apkscan.nviso.be/report/show/3362bd92a9f0cfaf49dfbeb5a406080c
# This script succesfully works on Sony Ericsson Xperia Mini Pro with CyanogenMod 9.
# To use it you will have to have FM Radio application installed.

### Settings:
# Path to the folder with logs:
LOGPATH=/mnt/sdcard/Android/FM_log/	#logs will have names YYYY-MM-DD.txt
###########

mkdir -p $LOGPATH
while true
do
	LOGDUMP=`logcat -d`	
	LASTPI=`busybox printf '%x' \`echo "$LOGDUMP" | grep "EVENT_PI_CODE " | tail -1 | cut -c 61-65\``
	LASTFREQ=`echo "$LOGDUMP" | grep "EVENT_TUNE_COMPLETE" | tail -1 | cut -c 72-76`
	LASTPS=`echo "$LOGDUMP" | grep "EVENT_PS_CHANGED " | tail -1 | cut -c 64-71`
	LASTRT=`echo "$LOGDUMP" | grep "EVENT_RDS_TEXT RDS:" | tail -1 | cut -c 63-126`
	echo -e "Old PI: $OLDPI\n    PI: $LASTPI" # Useful for debugging...
	echo -e "Old Freq: $OLDFREQ\n    Freq: $LASTFREQ" # Useful for debugging...
	echo -e "Old PS: $OLDPS\n    PS: $LASTPS" # Useful for debugging...
	echo -e "Old RT: $OLDRT\n    RT: $LASTRT" # Useful for debugging...
	# Frequency dump
	if [ "$LASTFREQ" != "" ] && [ "$LASTFREQ" != "$OLDFREQ" ] 
	then
		echo -e "Freq: $LASTFREQ" >> "$LOGPATH`busybox date -I`.txt"
		OLDFREQ=$LASTFREQ
		LASTPS=
		LASTPI=
		LASTRT=
	fi	
	# PI code dump
	if [ "$LASTPI" != "$OLDPI" ] && [ "$LASTPI" != "" ] && [ "$LASTPI" != "0" ]
	then
		OLDPI=$LASTPI
		am start -a android.intent.action.MAIN -e message "PI: $LASTPI" -n com.rja.utility/.ShowToast > /dev/null # Comment out "> /dev/null" for debugging
		echo -e "   Time: `date | cut -c 12-19`   PI: |$LASTPI|" >> "$LOGPATH`busybox date -I`.txt"
	fi	
	# PS name dump
	if [ "$LASTPS" != "$OLDPS" ] && [ "$LASTPS" != "" ]
	then
		OLDPS=$LASTPS
		echo -e "   Time: `date | cut -c 12-19`   PS: |$LASTPS|" >> "$LOGPATH`busybox date -I`.txt"
	fi
	# RT text dump
	if [ "$LASTRT" != "$OLDRT" ] && [ "$LASTRT" != "" ]
	then
		OLDRT=$LASTRT
		echo -e "   Time: `date | cut -c 12-19`   RT: |$LASTRT|" >> "$LOGPATH`busybox date -I`.txt"
	fi
	busybox sleep .3 # .3 means checking for new PI code every 0.3 second, you can change it to f.e. 3 for 3 seconds, 1m for 1 minute, etc.
done
