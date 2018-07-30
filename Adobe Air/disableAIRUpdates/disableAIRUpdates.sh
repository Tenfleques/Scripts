#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableAIRUpdates.sh
#
# Purpose:  Disables Adobe AIR updates, in the current user's
#           directory and the user template
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-30
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableAIRUpdates"

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
    userAppDir="/Users/${currentUser}/Library/Application Support/AIR"
    userFileDir="${userAppDir}/updateDisabled"

    mkdir -p "${userAppDir}"
    touch "${userFileDir}"
    chown -R "${currentUser}" "${userAppDir}"
}

configureTemplatePref ()
{
    for userTemplate in "/System/Library/User Template"/*;
    do
        templateAppDir="${userTemplate}/Library/Application Support/AIR"
        templateFileDir="${templateAppDir}/updateDisabled"

        mkdir -p "${templateAppDir}"
        touch "${templateFileDir}"
    done
}

##### Run script

echoVariables
userCheck

writelog "Current user is ${currentUser}"

configureUserPref
configureTemplatePref

writelog "Script completed."
