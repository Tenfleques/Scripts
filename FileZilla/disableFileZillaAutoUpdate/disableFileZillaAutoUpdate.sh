#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     disableFileZillaAutoUpdateAndFirstRun.sh
#
# Purpose:  Disables FileZilla AutoUpdate and First Run screens, in the current
#           user's directory and the user template
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-07-31
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="disableFileZillaAutoUpdateAndFirstRun"

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
    userConfDir="/Users/${currentUser}/.config/filezilla"
    userConfFile="${userConfDir}/filezilla.xml"

    if [[ ! -e "${userConfDir}" ]];
    then
        mkdir -p "${userConfDir}"
    fi

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "${userConfFile}"
    echo "<FileZilla3 version=\"3.34.0\" platform=\"mac\">" >> "${userConfFile}"
    echo "    <Settings>" >> "${userConfFile}"
    echo "        <Setting name=\"Update Check\">0</Setting>" >> "${userConfFile}"
    echo "        <Setting name=\"Update Check Interval\">7</Setting>" >> "${userConfFile}"
    echo "        <Setting name=\"Disable update footer\">0</Setting>" >> "${userConfFile}"
    echo "        <Setting name=\"Disable update check\">0</Setting>" >> "${userConfFile}"
    echo "        <Setting name=\"Greeting version\">4.0.0</Setting>" >> "${userConfFile}"
    echo "    </Settings>" >> "${userConfFile}"
    echo "</FileZilla3>" >> "${userConfFile}"

    chown -R "${currentUser}" "/Users/${currentUser}/.config"
}

configureTemplatePref ()
{
    for userTemplateDir in "/System/Library/User Template"/*
    do
        tempConfFile="${userTemplateDir}/.config/filezilla/filezilla.xml"

        if [[ ! -d "${userTemplateDir}/.config/filezilla" ]];
        then
            /bin/mkdir -p "${userTemplateDir}/.config/filezilla"
        fi

        touch "${tempConfFile}"
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "${tempConfFile}"
        echo "<FileZilla3 version=\"3.34.0\" platform=\"mac\">" >> "${tempConfFile}"
        echo "    <Settings>" >> "${tempConfFile}"
        echo "        <Setting name=\"Update Check\">0</Setting>" >> "${tempConfFile}"
        echo "        <Setting name=\"Update Check Interval\">7</Setting>" >> "${tempConfFile}"
        echo "        <Setting name=\"Disable update footer\">0</Setting>" >> "${tempConfFile}"
        echo "        <Setting name=\"Disable update check\">0</Setting>" >> "${tempConfFile}"
        echo "        <Setting name=\"Greeting version\">4.0.0</Setting>" >> "${tempConfFile}"
        echo "    </Settings>" >> "${tempConfFile}"
        echo "</FileZilla3>" >> "${tempConfFile}"
    done
}

##### Run script

echoVariables
userCheck

writelog "Current user is ${currentUser}"

configureUserPref
configureTemplatePref

writelog "Script completed."
