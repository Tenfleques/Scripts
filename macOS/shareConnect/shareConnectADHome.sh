#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     shareConnectADHome.sh
#
# Purpose:  Checks dscl for the user's SMBHome attribute and mounts their home
#           if found
# Usage:    Jamf Pro login policy
#
# Version 1.0.0, 2018-07-24
#   SB - Initial Creation

# Use at your own risk. Moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Set variables

logProcess="shareConnectADHome"
currentUser="${3}"

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
    writelog "User Name is ${currentUser}"
}

checkUsername ()
{
    # Checks if the username variable is empty (user running script from Self Service)
    if [[ -z "${currentUser}" ]];
    then
        currentUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    fi
}

checkForMount ()
{
    isMounted=$(/sbin/mount | grep -c "/Volumes/${currentUser}")
    if [[ "${isMounted}" -ne 0 ]];
    then
    	writelog "Network share already mounted for ${currentUser}. Exiting..."
    	exit 0
    fi
}

domainCheck ()
{
    # Flush dscl
    /usr/bin/dscacheutil -flushcache
    writelog "Retrieving SMBHome attribute for ${currentUser}..."

    # Next we perform a quick check to make sure that the SMBHome attribute is populated
    smbhomeResult=invalid
    retries=1
    while [[ "${smbhomeResult}" == "invalid" && "${retries}" -le 5 ]];
    do
        writelog "Attempt ${retries}..."

        # Get Domain from full structure, cut the name and remove space.
        shortDomain=$(/usr/bin/dscl /Active\ Directory/ -read . | grep SubNodes | sed 's|SubNodes: ||g')
        writelog "Domain short name identified as as ${shortDomain}"

        # Find the user's SMBHome attribue, strip the leading \\ and swap the remaining \ in the path to /. The result is to turn smbhome: \\server.domain.com\path\to\home into server.domain.com/path/to/home
        adHome=$(/usr/bin/dscl /Active\ Directory/${shortDomain}/All\ Domains -read /Users/${currentUser} SMBHome | sed 's|SMBHome:||g' | sed 's/^[\\]*//' | sed 's:\\:/:g' | sed 's/ \/\///g' | tr -d '\n' | sed 's/ /%20/g')
        writelog "${currentUser} SMBHome Identified as as ${adHome}"

        # case statement
        case "${adHome}" in
            "" )
        	    writelog "${currentUser} SMBHome attribute does not have a value set, or ${currentUser} is a local user. Exiting..."
                smbhomeResult=local
        	    # exit 0
                ;;
            "name:%20dsRecTypeStandard:Users" )
                writelog "${currentUser} SMBHome attribute invalid."
                smbhomeResult=invalid
                # exit 1
                ;;
            *"%20is%20not%20valid." )
            	writelog "${currentUser} SMBHome attribute invalid."
                smbhomeResult=invalid
                # exit 1
                ;;
            * )
        	    writelog "${currentUser} SMBHome attribute identified as ${adHome}. Continuing..."
                smbhomeResult=valid
        	    ;;
        esac

        # Increment
        ((retries++))

        # Wait for 5 seconds if the attempt was invalid
        if [[ "${smbhomeResult}" == "invalid" ]];
        then
            sleep 5
        fi
    done

    if [[ "${smbhomeResult}" == "local" ]];
    then
        exit 0
    elif [[ "${smbhomeResult}" == "invalid" ]];
    then
        writelog "Maximum tries exceeded. Bailing..."
        exit 1
    fi
}

mountHome ()
{
    /usr/bin/osascript > /dev/null << EOT
    mount volume "smb://${adHome}"
EOT
    exitStatus="${?}"
}

##### Run script

echoVariables
checkUsername
checkForMount
domainCheck
mountHome

writelog "Script completed."
