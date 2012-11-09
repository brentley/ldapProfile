# Retrieving Your Bash Profile from LDAP

This is a collection of files I currently use to provide "roaming" dot profiles.  When a user connects, the /etc/profile.d/ldapprofile.sh script calls getldapprofile to retrieve the contents of bashProfile from dn: uid=$USER,ou=example,ou=org.

I've also included my schema extension, and a few other scripts I use to extend the schema for our existing users, add the user's custom bash_profile, and remove the custom bash_profile if necessary.

Everything is formatted to be compatible with Fedora Directory Server, Red Hat Enterprise Directory Server, or Sun One.  It is easily adapted to openldap.

Description
===========
I've created a schema that supports storing user specific custom dot files in LDAP.  Currently with this schema, you can store your custom bash profile, screenrc, vimrc, tmuxrc and bash logout.  These ldap entries are user-serviceable, so they can be edited as much as desired, without involving the LDAP administrator.  

Usage
-----
Two scripts provide the "upload" and "delete" function for the supported attributes.  To upload:

    $ ldap-uploadattribute 
    Usage: /usr/local/bin/ldap-uploadattribute ATTRIBUTE_NAME FILE
    Supported Attributes:
     bashProfile
     bashProfile2
     bashProfile3
     screenrc
     vimrc
     tmuxrc
     bashLogout
    $ ldap-delattribute 
    Usage: /usr/local/bin/ldap-delattribute ATTRIBUTE_NAME
    Supported Attributes:
     bashProfile
     bashProfile2
     bashProfile3
     screenrc
     vimrc
     tmuxrc
     bashLogout

Editing
-------
The bash profile attributes will be sourced directly from ldap, and not ever written to disk.  To edit those, you can use "ldapcat ATTRIBUTE_NAME" command to cat the contents of that attribute to a file, edit, then "ldap-uploadattribute" to upload your changed file.

All other attributes are written to the appropriate dot file in your home directory upon login. Just edit that file directly, and "ldap-uploadattribute" the changed content.

Updating
--------
To protect existing local dot files from being overwritten,
the ldap version has to be commented with:

    # LDAP_STORED_VERSION=X

Where X is the latest version of your file.

By doing this you are ensured you have the latest copy of 
your dot file, and don't overwrite local copies that
may have been customized.

Use the ldap-uploadattribute command to push your 
dot file to the ldap server, and ldap-deleteattribute to 
remove your dot file from the ldap server.

Note: Doublequote (") is the comment character for .vimrc

Note2: Since bashProfile is never written to disk, this version mechanism is not necessary for the bashProfile attribute.  Other dot files written to disk *do* need versions, though.

Deleting
--------
To remove the contents of an attribute from your LDAP profile, use the "ldap-delattribute" command. This will clear the content of the attribute from your profile.  Upon next login, these dot files will be truncated.

Size restriction
----------------
The maximum file size of a dot file in ldap is 3060 bytes.  After encoding, this will be stored as a maximum 4096 byte ldap entry.  Because of this restriction, I've created 3 bash profile attributes that are sourced in order. You can break up your large profile into these 3 attributes to work around the 3060 byte limit.

Additional Dot Files
--------------------
Adding additional dot files is accomplished with a schema change. 

93-profile.ldif
---------------
This is a schema extension that adds an Auxiliary class compatible with inetorgperson. It is formatted to be compatible with Fedora Directory Server. It should be compatible with a Sun ONE directory server also, and easily adaptable to openldap and others.  

ldapcat
--------------
This ruby script retrievs the attribute contents you ask for from ldap matching based on your local username. It depends on the net-ldap gem. (gem install net-ldap)

ldapprofile.sh
--------------
This script adds the output of getldapprofile to the existing environment.  Deploy this to /etc/profile.d/

otherfiles.sh
--------------
This script outputs the listed attributes to the user's $HOME/(dotfiles).  Deploy this to /etc/profile.d/

ldap-extendschema-profile
------------------
This script extends the schema for existing users to allow the additional ldapProfile attributes (defined in 93-profile.ldif).

ldap-uploadattribute
---------------
This user self-servicable script adds the contents of a file to a user's specified attribute. There appears to be a limit of 3060 bytes for the filesize.

ldap-delattribute
---------------
This user self-servicable script removes the contents of the specified attribute.

aci.ldif
--------
This aci allows for user self service

