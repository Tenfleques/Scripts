#!/bin/bash

# Add all users to lpadmins
/usr/sbin/dseditgroup -o edit -t group -a everyone _lpadmin
