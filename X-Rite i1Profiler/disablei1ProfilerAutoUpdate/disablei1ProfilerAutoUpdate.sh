#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disablei1ProfilerAutoUpdate.sh
#
# Purpose:  Disables i1Profiler AutoUpdate in the Library folder
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-31
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disablei1ProfilerAutoUpdate"

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

configureUserPref ()
{
    userConfDir="/Library/Application Support/X-Rite/i1Profiler"
    userConfFile="${userConfDir}/XRi1G2WorkflowSettings.ini"

    if [[ ! -e "${userConfDir}" ]];
    then
        mkdir -p "${userConfDir}"
    fi

    echo "[General]" > "${userConfFile}"
    echo "CheckUpdatesAtStartup=false" >> "${userConfFile}"

    chmod -R root:wheel "${userConfFile}"
    chmod -R 777 "${userConfFile}"
}

##### Run script

echoVariables
configureUserPref

writelog "Script completed."
