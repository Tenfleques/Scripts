#!/bin/bash

# Disable Network Share Verification
writelog "Disabling Server Verification..."
/usr/bin/defaults write /Library/Preferences/com.apple.NetworkAuthorization AllowUnknownServers -bool YES
