#!/bin/bash
if [ "$(whoami)" != "root ]; then
  echo "RUN AS ROOT!"
  exit 1
fi
echo "Adding daily cronjob"
cp backup.sh /usr/bin
cp options.sh /usr/bin
(crontab -l ; echo "@daily bash /usr/bin/backup.sh") | crontab -
