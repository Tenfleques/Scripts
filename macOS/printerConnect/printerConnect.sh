#!/bin/bash

# Author:   Stephen Bygrave - Moof IT
# Name:     printerConnect.sh
#
# Purpose:  Assumes print drivers are installed on device; sets up a printer
#           using LPD with various options.
#           PLEASE NOTE: $9 should always have at least one option speficied;
#           recommended `-o PageSize=A4` or `-o PageSize=Letter`. If not, this
#           script will fail.
# Usage:    Jamf Pro script
#
# Version 1.0.0, 2018-02-13
#   SB - Initial Creation

# Use at your own risk. moof IT will accept no responsibility for loss or damage
# caused by this script.

##### Parameter Explanations

# $4 = This is the name of the printer, e.g. MyGreatPrinter
# $5 = This is the URL of the printer, e.g. ipp://fp01.ac.uk/printers/printer1
# $6 = This is the path to the ppd file, e.g. /Library/Printers/PPDs/Contents/Resources/HP LaserJet 4000 Series.gz
# $7 = This is the GUI location of the printer, e.g. Poland Street
# $8 = Set this to 'Yes' to enable SSO printing
# $9 = This is a one line string of options that should be seperated with spaces, and an "-o" before each option

##### Set variables

logProcess="printerConnect"
printerName="${4}"
printerUrl="${5}"
ppd="${6}"
printerLocation="${7}"
ssoPrinting="${8}"
additionalOptions="${9}"

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
    writelog "Printer Name: ${printerName}"
    writelog "Printer URL: ${printerUrl}"
    writelog "PPD Location: ${ppd}"
    writelog "Printer Location: ${printerLocation}"
    writelog "SSO Printing: ${ssoPrinting}"
    writelog "Additional Options: ${additionalOptions}"
}

testForPrinter ()
{
    for printerCheck in $(/usr/bin/lpstat -p | awk '{print $2}');
    do
        if [[ "${printerCheck}" == "${printerName}" ]];
        then
            /usr/sbin/lpadmin -x "${printerName}"
        fi
    done
}

addPrinter ()
{
    if [[ "${ssoPrinting}" == "Yes" ]];
    then
        /usr/sbin/lpadmin -p "${printerName}" -v "${printerUrl}" -L "${printerLocation}" -P "${ppd}" -D "${printerName}" -E -o printer-is-shared=false -o printer-error-policy="retry-current-job" -o auth-info-required=negotiate "${additionalOptions}"
    else
        /usr/sbin/lpadmin -p "${printerName}" -v "${printerUrl}" -L "${printerLocation}" -P "${ppd}" -D "${printerName}" -E -o printer-is-shared=false -o printer-error-policy="retry-current-job" "${additionalOptions}"
    fi
}

##### Run script

echoVariables
testForPrinter
addPrinter

writelog "Script completed."
