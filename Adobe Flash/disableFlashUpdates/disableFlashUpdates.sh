#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableFlashUpdates.sh
#
# Purpose:  Disables Adobe Flash updates, in the Library folder
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-30
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableFlashUpdates"
configDir="/Library/Application Support/Macromedia"
configFile="/Library/Application Support/Macromedia/mms.cfg"

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

testForConfigDir ()
{
    if [[ ! -d "${configDir}" ]];
    then
        echo "Configuration folder not found. Creating..."
        mkdir "${configDir}"
    fi
}

createConfigFile ()
{
    echo "Configuraton file not found. Creating..."
    echo "AutoUpdateDisable=1" > "${configFile}"
    echo "SilentAutoUpdateEnable=0" >> "${configFile}"
}

##### Run script

echoVariables
testForConfigDir
createConfigFile

writelog "Script completed."
