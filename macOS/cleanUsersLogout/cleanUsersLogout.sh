#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     cleanUsersLogout.sh
#
# Purpose:  This script looks though the Users folder, and removes all users
#           with the exception of a defined list.
# Usage:    Script that runs on logout
#
# Version 1.0.0, 2018-07-24
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Parameter Explanations

# $4 = User to omit 1
# $5 = User to omit 2
# $6 = User to omit 3
# $7 = User to omit 4

##### Set variables

logProcess="deleteUsersAtLogout"
username1="${4}"
if [[ -z "${username1}" ]];
then
    username1=null
fi
username2="${5}"
if [[ -z "${username2}" ]];
then
    username2=null
fi
username3="${6}"
if [[ -z "${username3}" ]];
then
    username3=null
fi
username4="${7}"
if [[ -z "${username4}" ]];
then
    username4=null
fi

##### Declare functions

writelog ()
{
    /usr/bin/logger -is -t "${logProcess}" "${1}"
    if [[ -e "/var/log/jamf.log" ]];
    then
        /bin/echo "$(date +"%a %b %d %T") $(hostname -f | awk -F "." '{print $1}') jamf[${logProcess}]: ${1}" >> "/var/log/jamf.log"
    fi
}

echoVariables ()
{
    writelog "Log Process is ${logProcess}"
    writelog "Username 1 is ${username1}"
    writelog "Username 2 is ${username2}"
    writelog "Username 3 is ${username3}"
    writelog "Username 4 is ${username4}"
}

##### Run script

echoVariables
fail="0"
writelog "Starting Delete all local users script..."

for userName in $(ls "/Users" | grep -v -e "Shared" -e "Guest" -e "${username1}" -e "${username2}" -e "${username3}" -e "${username4}");
do
	writelog "Target user ${userName} found, removing local home..."
	/bin/rm -rf "/Users/${userName}"
	if [[ "${?}" != 0 ]];
    then
		writelog "Failed to remove ${userName} home folder at /Users/${userName}."
		fail="1"
	else
		writelog "Successfully removed ${userName} home folder."
		writelog "Running sysadminctl delete to ensure ${userName} account is removed..."
		/usr/sbin/sysadminctl -deleteUser "${userName}"
		writelog "Removed user account: ${userName}."
		writelog "Removing user's MCX folder..."
		/bin/rm -Rf "/Library/Managed Preferences/${userName}"
	fi
done

writelog "Script completed."

if [ "${fail}" != "0" ]; then
	exit 1
else
	exit 0
fi
