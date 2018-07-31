#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableArduinoAutoUpdate.sh
#
# Purpose:  Disables Arduino AutoUpdate in the current user's directory and the
#           user template
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-31
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableArduinoAutoUpdate"

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

userCheck ()
{
    currentUser="$3"

    # Checks if the variable is empty (user running script from Self Service)
    if [[ -z "${currentUser}" || "${currentUser}" == "root" ]];
    then
         currentUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    fi
}

configureUserPref ()
{
    userConfDir="/Users/${currentUser}/Library/Arduino15"
    userConfFile="${userConfDir}/preferences.txt"

    if [[ ! -e "${userConfDir}" ]];
    then
        mkdir -p "${userConfDir}"
    fi

    echo "update.check=false" > "${userConfFile}"

    chown -R "${currentUser}" "${userConfDir}"
}

configureTemplatePref ()
{
    for userTemplateDir in "/System/Library/User Template"/*
    do
        tempConfFile="${userTemplateDir}/Library/Arduino15/preferences.txt"

        if [[ ! -d "${userTemplateDir}/Library/Arduino15" ]];
        then
            /bin/mkdir -p "${userTemplateDir}/Library/Arduino15"
        fi

        touch "${tempConfFile}"
        echo "update.check=false" > "${tempConfFile}"
    done
}

##### Run script

echoVariables
userCheck

writelog "Current user is ${currentUser}"

configureUserPref
configureTemplatePref

writelog "Script completed."
