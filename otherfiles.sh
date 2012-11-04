#!/bin/bash

# only run if this is a login shell for an ldap user
# our ldap accounts start at 4000
if [ $UID -gt 3999 ] && [ -d $HOME ] && shopt -q login_shell ; then

LDAPCAT=/usr/local/bin/ldapcat

# when calling this function:
# $1 is attribute name $2 is filename
checkfiles() {

LDAPCONTENT="$($LDAPCAT $1)"

# if the attribute isn't populated in ldap, don't bother finishing the function
if [ $? -gt 0 ]; then return; fi

# if the file dosn't exist OR does, but is zero bytes
if [ ! -f $HOME/$2 ] || ([ -f $HOME/$2 ] && [ ! -s $HOME/$2 ])
then
    echo "$LDAPCONTENT" $1 > $HOME/$2 2>/dev/null
    return
fi

# pick out the version number of the attribute 
LDAP=$(echo "$LDAPCONTENT" |awk -F= '/LDAP_STORED_VERSION=/ { print $2 }' 2>/dev/null)
# pick out the version number of the local file
ONDISK=$(cat $HOME/$2 2>/dev/null | awk -F= '/LDAP_STORED_VERSION=/ { print $2 }')

# if we have a file version AND an ldap version AND file < ldap
if [ -n "$ONDISK" ] && [ -n "$LDAP" ] && [ "$ONDISK" -lt "$LDAP" ]
then
    echo "$LDAPCONTENT" $1 > $HOME/$2 2>/dev/null
fi 2>/dev/null

}

# checkfiles attribute_name file_name
checkfiles screenrc .screenrc
checkfiles vimrc .vimrc
checkfiles tmuxrc .tmuxrc
checkfiles bashLogout .bash_logout

# save a README to explain how to store these files
cat> ~/.dotfiles_README <<EoF
We are now able to store certain custom dot files in ldap.

Currently we support storing .bashrc, .vimrc, .screenrc, 
.tmuxrc, and .bash_logout in ldap.

If additional support is added, this file will be edited.

To protect existing local files from being overwritten,
the ldap version has to be commented with:

# LDAP_STORED_VERSION=X

Where X is the latest version of your file.

Note: doublequote (") is the comment character for .vimrc

By doing this we can ensure you have the latest copy of 
your dot file, and don't overwrite local copies that
may have been customized.

Use the ldap-uploadattribute command to push your 
dot file to the ldap server, and ldap-deleteattribute to 
remove your dot file from the ldap server.

There is currently a 3060 byte limitation per dot file.

See https://tumblr.atlassian.net/wiki/pages/viewpage.action?pageId=14614627
for the latest full documentation on this feature.
EoF

fi
