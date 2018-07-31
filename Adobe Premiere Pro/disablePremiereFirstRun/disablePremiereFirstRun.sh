#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disablePremiereFirstRun.sh
#
# Purpose:  Disables the Premiere Pro first run screen
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-31
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disablePremiereFirstRun"
video="/Users/Shared/Adobe/Premiere Pro/11.0/Tutorial/OnboardingLoop.mp4"

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

disableVideo ()
{
    if [[ -a "${video}" ]];
    then
        echo "video ${video} found, renaming..."
        mv "${video}" "${video}-OFF"
    else
        echo "video ${video} NOT found."
    fi
}

##### Run script

echoVariables
disableVideo

writelog "Script completed."
