#!/bin/bash

# only query ldap if you have an account
# our ldap accounts start at 4000
if [ $UID -gt 3999 ] ; then

eval "$(/usr/local/bin/ldapcat bashProfile 2>/dev/null)"
eval "$(/usr/local/bin/ldapcat bashProfile2 2>/dev/null)"
eval "$(/usr/local/bin/ldapcat bashProfile3 2>/dev/null)"

fi
