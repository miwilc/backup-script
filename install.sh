#!/bin/bash
if [ "$(whoami)" != "root ]; then
  echo "RUN AS ROOT!"
  exit 1
fi
echo "Adding daily cronjob"
cp backup.sh /usr/bin
mkdir ~/backup-settings
cp options.sh ~/backup-settings
(crontab -l ; echo "@daily bash /usr/bin/backup.sh") | crontab -
