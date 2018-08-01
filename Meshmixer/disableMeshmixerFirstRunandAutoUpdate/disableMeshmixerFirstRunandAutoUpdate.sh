#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableMeshmixerFirstRunandAutoUpdate.sh
#
# Purpose:  Disables Meshmixer's first run prompts from the user home and
#           template folders.
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-08-01
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableMeshmixerFirstRunandAutoUpdate"
meshmixerApp="/Applications/Meshmixer.app"

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
    userPrefDir="/Users/${currentUser}/.config/Autodesk"
    userPrefFile="${userPrefDir}/meshmixer.ini"

    # Check for Meshmixer config file and create if doesn't exist
    if [[ ! -a "${userPrefFile}" ]];
    then
        writelog "Existing prefs file not found. Adding..."
        mkdir -p "${userPrefDir}"
        touch "${userPrefFile}"
    fi

    # Create Meskmixer config file
    echo "[ApplicationSettings]" > "${userPrefFile}"
    echo "CheckUpdates=false" >> "${userPrefFile}"
    echo "" >> "${userPrefFile}"
    echo "[Licensing]" >> "${userPrefFile}"
    echo "Key=3735928562" >> "${userPrefFile}"
    echo "" >> "${userPrefFile}"
    echo "[Options]" >> "${userPrefFile}"
    echo "CollectingAnalyticsDataV3=false" >> "${userPrefFile}"
    echo "FirstInstallationDone=true" >> "${userPrefFile}"
    echo "SentLicenseMacInfo=false" >> "${userPrefFile}"
    echo "UserPreferenceForDataCollectionSet2=true" >> "${userPrefFile}"
    echo "UserPreferenceForDataCollectionSetV3=true" >> "${userPrefFile}"

    chown -R "${currentUser}" "${userPrefDir}"

    # Copy Meshmixer requirements from Appliation bundle
    cp -r "${meshmixerApp}/Contents/Resources/meshmixer" "/Users/${currentUser}/Documents/"
    chown -R "${currentUser}" "/Users/${currentUser}/Documents/meshmixer"
}

disableUserTemplate ()
{
    for userTemplate in "/System/Library/User Template"/*;
    do
        tempPrefDir="${userTemplate}/.config/Autodesk"
        tempPrefFile="${tempPrefDir}/meshmixer.ini"

        # Check for Meshmixer config file and create if doesn't exist
        if [[ ! -d "${tempPrefDir}" ]]; then
            mkdir -p "${tempPrefDir}"
            touch "${tempPrefFile}"
        fi

        # Create Meskmixer config file
        echo "[ApplicationSettings]" > "${tempPrefFile}"
        echo "CheckUpdates=false" >> "${tempPrefFile}"
        echo "" >> "${tempPrefFile}"
        echo "[Licensing]" >> "${tempPrefFile}"
        echo "Key=3735928562" >> "${tempPrefFile}"
        echo "" >> "${tempPrefFile}"
        echo "[Options]" >> "${tempPrefFile}"
        echo "CollectingAnalyticsDataV3=false" >> "${tempPrefFile}"
        echo "FirstInstallationDone=true" >> "${tempPrefFile}"
        echo "SentLicenseMacInfo=false" >> "${tempPrefFile}"
        echo "UserPreferenceForDataCollectionSet2=true" >> "${tempPrefFile}"
        echo "UserPreferenceForDataCollectionSetV3=true" >> "${tempPrefFile}"

        # Copy Meshmixer requirements from Appliation bundle
        if [[ ! -d "${userTemplate}/Documents/" ]]; then
            mkdir -p "${userTemplate}/Documents/"
        fi
        cp -r "${meshmixerApp}/Contents/Resources/meshmixer" "${userTemplate}/Documents/"
    done
}

##### Run script

echoVariables
checkUser
disableCurrentUser
disableUserTemplate

writelog "Script completed."
