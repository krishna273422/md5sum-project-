#!/bin/bash

#debugflagset to check on step by step scriptrun
#set -x

#Variable declaration
#store the md5 hash from /etc/passwd

md5_userfile="$(awk -F: '{ print $1":"$6}' /etc/passwd )"

#check the necessary files are available in /var/log - current_users and user_changes
#If the files are not available create it and add permission to 666

if [[ ! -f "/var/log/current_users" && ! -f "/var/log/user_changes" ]]
then
    echo "Creating current_users and user_changes files to log path"
    touch /var/log/current_users /var/log/user_changes
    chmod 666 /var/log/current_users && chmod 666 /var/log/user_changes
fi

# File checking and logs
# checks if the file current users is empty, if not collect the contents and map to current_md5users
# check if current and md5_userfile is same, then update no changes
# else copy the userfile to current users and update the changes log with date stamp to users_changes

if [ -s /var/log/current_users ]; then
  current_md5users=`cat /var/log/current_users`
   if [ "$md5_userfile" == "$current_md5users" ];then
      echo "No changes in the MD5 hash detected"
   else
      echo "$md5_userfile" > "/var/log/current_users"
      echo "A change occured in the MD5 hash"
      now=$(date +"%m_%d_%Y_%T")
      echo "$now changes occured" > "/var/log/user_changes"
   fi
else
#storing the md5sum to file
  echo "Storing the MD5sum hash into the file current_users"
  echo "$md5_userfile" > "/var/log/current_users"
fi
