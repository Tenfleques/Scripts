#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     shareConnect.sh
#
# Purpose:  Mounts a share on login
# Usage:    Script in Jamf Pro policy
#
# Version 1.0.0, 2018-04-17
#   Initial Creation

# Use at your own risk. moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Parameter Explanations

# $4 = This is the protocol to be used when mounting a share, e.g. afp
# $5 = This is the hostname of the server, e.g. server1, or server1.muyrg.local
# $6 = This is the name of the share to be mounted, e.g. data

##### Set variables

logProcess="shareConnect"
currentUser="${3}"
protocol="${4}"
serverName="${5}"
shareName="${6}"

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
    writelog "Log Process: ${logProcess}"
    writelog "User: ${currentUser}"
    writelog "Protocol: ${protocol}"
    writelog "Server: ${serverName}"
    writelog "Sharename: ${shareName}"
}

checkUsername ()
{
    # Checks if the username variable is empty (user running script from Self Service)
    if [[ -z "${currentUser}" ]];
    then
        currentUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    fi
}

domainCheck ()
{
    # Flush dscl
    /usr/bin/dscacheutil -flushcache
    writelog "Retrieving RecordName attribute for ${currentUser}..."

    # Next we perform a quick check to make sure that the SMBHome attribute is populated
    recordNameResult=invalid
    retries=1
    while [[ "${recordNameResult}" == "invalid" && "${retries}" -le 5 ]];
    do
        writelog "Attempt ${retries}..."

        # Get Domain from full structure, cut the name and remove space.
        shortDomain=$(/usr/bin/dscl /Active\ Directory/ -read . | grep SubNodes | sed 's|SubNodes: ||g')
        writelog "Domain short name identified as as ${shortDomain}"

        # Find the user's SMBHome attribue, strip the leading \\ and swap the remaining \ in the path to /. The result is to turn smbhome: \\server.domain.com\path\to\home into server.domain.com/path/to/home
        adRecordName=$(/usr/bin/dscl /Active\ Directory/${shortDomain}/All\ Domains -read /Users/${currentUser} RecordName | awk '{print $2}')
        writelog "Current user's AD Record Name is ${adRecordName}"

        # Check for local or non-local
        if [[ "${adRecordName}" == "" ]];
        then
            writelog "${currentUser} RecordName attribute does not have a value set, or ${currentUser} is a local user. Exiting..."
            recordNameResult=local
        elif [[ "${currentUser}" != *"${adRecordName}"* ]];
        then
            writelog "Current username ${currentUser} and AD Record Name ${adRecordName} do not match."
            recordNameResult=invalid
        elif [[ "${currentUser}" == *"${adRecordName}"* ]];
        then
            writelog "Current username ${currentUser} and AD Record Name ${adRecordName} match. Continuing..."
            recordNameResult=valid
        fi

        # Increment
        ((retries++))

        # Wait for 5 seconds if the attempt was invalid
        if [[ "${recordNameResult}" == "invalid" ]];
        then
            sleep 5
        fi
    done

    if [[ "${recordNameResult}" == "local" ]];
    then
        exit 0
    elif [[ "${recordNameResult}" == "invalid" ]];
    then
        writelog "Maximum tries exceeded. Bailing..."
        exit 1
    fi
}

mountShare ()
{
    /usr/bin/osascript > /dev/null << EOT
    mount volume "${protocol}://${serverName}/${shareName}"
EOT
    exitStatus="${?}"
}

##### Run script

echoVariables
checkUsername
domainCheck
mountShare

writelog "Script completed."
