#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableDreamweaverFirstRun.sh
#
# Purpose:  Disables the Dreamweaver first run prompts from the user home and
#           template folders
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-30
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableDreamweaverFirstRun"

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
}

checkUser ()
{
    currentUser="$3"
    if [[ -z "${currentUser}" ]];
    then
         currentUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    fi
    writelog "Current user is ${currentUser}"
}

disableCurrentUser ()
{
    userPrefFile="/Users/${currentUser}/Library/Preferences/Adobe Dreamweaver CC 2018 Prefs"
    if [[ ! -a "${userPrefFile}" ]];
    then
        writelog "Existing prefs file not found. Adding..."
        touch "${userPrefFile}"
    fi
    echo "[NEW FEATURE WALKTHROUGH]" >> "${userPrefFile}"
    echo "stage 1 done=TRUE" >> "${userPrefFile}"
    chown -R "${currentUser}" "${userPrefFile}"
}

disableUserTemplate ()
{
    for userTemplate in "/System/Library/User Template"/*;
    do
        templatePrefFile="${userTemplate}/Library/Preferences/Adobe Dreamweaver CC 2018 Prefs"
        if [[ ! -a "${templatePrefFile}" ]];
        then
            writelog "Existing prefs file not found. Adding..."
            touch "${templatePrefFile}"
        fi
        echo "[NEW FEATURE WALKTHROUGH]" >> "${templatePrefFile}"
        echo "stage 1 done=TRUE" >> "${templatePrefFile}"
    done
}

##### Run script

echoVariables
checkUser
disableCurrentUser
disableUserTemplate

writelog "Script completed."
