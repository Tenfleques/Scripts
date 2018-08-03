#!/bin/bash

# $4 is the user that needs to be hidden

# Hide User
/usr/bin/dscl . create "/Users/${4}" IsHidden 1
