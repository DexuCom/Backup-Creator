#!/bin/bash

# Author : Patryk Sawuk ( s193059@student.pg.edu.pl )
# Created On : 08.04.2023
# Last Modified By : Patryk Sawuk ( s193059@student.pg.edu.pl )
# Last Modified On : 16.04.2023
# Version : 1.4
#
# Description : Program that creates Backup file
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


TITLE="Backup Creator"
menu=("Create backup" "Set time to cycle backup" "Turn off cycle backup" "Delete backup file" "Restore choosen file")

function prepareVariables() {
	TIMEOUT=""
	FILE=""
	BACKUP_DIR=""
	BACKUP_FILE=""
	DELETE_FILE=""
	RESTORE_DIR=""
	RESTORE_FILE=""
}

function ustawTime() {
	while true; do
		TIME=$(zenity --entry --title "Cycle Backup" --text "Give number of seconds how often do you want to cycle backup")
		if [[ $? -eq 1 ]]; then
			break
		fi
		if [[ $TIME =~ ^[0-9]+$ ]]; then
			TIMEOUT="--timeout $TIME "
			break
		else
			zenity --error --text "You didn't gave proper number"
		fi
	done
}

function setBackup() { #Function to Set Backup
	if zenity --question --text="Do you want to save files or directory?" --cancel-label "Directory" --ok-label "Files"; then
		FILE=$(zenity --file-selection --multiple --title="Select file to backup")
		FILE=$(echo "$FILE" | tr '|' ' ')
	else
		FILE=$(zenity --file-selection --directory --title="Select directory to backup")
	fi
	
	BACKUP_DIR=$(zenity --file-selection --directory --title="Select backup location")
	TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	BACKUP_FILE="$BACKUP_DIR/$(basename -- $FILE)_backup_$TIMESTAMP.tar.gz"

	if [ -d "$FILE" ]; then
		tar -czvf $BACKUP_FILE -C $(dirname -- $FILE)/ --transform 's|.*|&|' $(basename -- $FILE)
	else
		tar -czvf $BACKUP_FILE --transform 's|.*/||' $FILE
	fi

	if zenity --question --text="Do you want to turn on cycle buckup?"; then
		ustawTime
	fi
}

function deleteBackup() {
	rm $DELETE_FILE
}

function restoreBackup() {
	RESTORE_FILE=$BACKUP_FILE
	RESTORE_DIR=$(dirname -- $FILE)
	TIMEOUT=""

	tar -xzf $RESTORE_FILE -C $RESTORE_DIR
	zenity --info --text="File restored successfully"
}

function pomoc() {

	echo "If you have any questions or want to report any issue"
	echo "Contact: s193059@student.pg.edu.pl"
}

function wersja() {

	echo "Backup Creator version: 1.4"
}

prepareVariables

while getopts hv OPT; do
	case $OPT in

		h) pomoc;;
		v) wersja;;
		*) echo "Nieznana opcja";;

	esac
done

while true; do

	#Main Menu
	option=$(zenity $TIMEOUT--list --height 500 --width 300 --title="$TITLE" --text="Program that creates Backup of a file" \
	--cancel-label "Leave" --ok-label "Choose option" --column="Main menu" "${menu[@]}")
	#---------

	if [[ $? -eq 1 ]]; then #Exit
		break
	fi

	case "$option" in
		"${menu[0]}" )

			if [ ! -z "$BACKUP_FILE" ]; then #Create Backup
				if zenity --question --text="Are you sure to create new backup?\n(Old backup will be deleted)"; then
					DELETE_FILE=$BACKUP_FILE #Create if you want to delete previous file
					deleteBackup
					prepareVariables
					setBackup
				fi
			else 
				setBackup
			fi;;

		"${menu[1]}" ) #Set Cycle Time

			if [ ! -z "$BACKUP_FILE" ]; then
				ustawTime
			else
				zenity --error --text="There is no backup file set"
			fi;;

		"${menu[2]}" ) #Delete Cycle Time

			if [ ! -z "$BACKUP_FILE" ]; then
				if zenity --question --text="Are you sure you want to turn off cycle backup?" --cancel-label "No" --ok-label "Yes"; then
					TIMEOUT=""
					zenity --warning --text="You've turned off cycle backup"
				fi
			else
				zenity --error --text="There is no backup file set"
			fi;;

		"${menu[3]}" ) #Delete Backup (if there is any)

			if [ ! -z "$BACKUP_FILE" ]; then
				DELETE_FILE=$BACKUP_FILE
				if zenity --question --text="Are you sure you want to delete $DELETE_FILE?"; then
					deleteBackup
					zenity --info --text="Backup file deleted successfully."
					prepareVariables
				else
					zenity --info --text="Backup file not deleted."
				fi
			else
				zenity --error --text="There is no backup file set"
			fi;;	

		"${menu[4]}" ) #Restore Backup

			if [ ! -z "$BACKUP_FILE" ]; then
				restoreBackup
				DELETE_FILE=$BACKUP_FILE
				deleteBackup
				prepareVariables

			else
				zenity --error --text="There is no backup file set"
			fi;;

		* ) if [ ! -z "$TIMEOUT" ]; then #Cycle Backup Init
				if [ -d "$FILE" ]; then
					tar -czvf $BACKUP_FILE -C $(dirname -- $FILE)/ --transform 's|.*|&|' $(basename -- $FILE)
				else
					tar -czvf $BACKUP_FILE --transform 's|.*/||' $FILE
				fi
			fi;;
	esac

done