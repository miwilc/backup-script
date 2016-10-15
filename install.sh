#!/bin/bash
echo "A simple backup script - Installer"
echo " by 1Conan (github.com/1Conan)"
if [ "$(whoami)" != "root" ]; then
  echo "RUN AS ROOT!"
  exit 1
fi
read -r -p "Enter a unique server ID name: " id_name

read -r -p "Do you want to include MySQL/MariaDB bacups? (Y/N) [N]: " resp

if [[ "$resp" == "y" || "$resp" == "Y" ]]; then
	ENABLE_MYSQL=true
	read -r -p "Enter MySQL root password: " msql_rootpass
else
	ENABLE_MYSQL=false
fi
TMP_COUNT=0
while true; do
	read -r -p "Enter directory to be backed up (Type done when done) [$(expr ${TMP_COUNT} + 1)]: " DIR_PATH
	if [ -f "${DIR_PATH}" ]; then
		echo "Not a directory!"
		exit
	elif [ -d "${DIR_PATH}" ]; then
		DIRS="DIR[${TMP_COUNT}]=${DIR_PATH};${DIRS}"
	else [ "${DIR_PATH}" == "done" ]; then
		break
	fi
done

read -r -p "Enter file path where backups will be stored (Include trailing slash): " backup_path

mkdir /usr/local/backup-settings
cat <<EOF > /usr/local/backup-settings/options.sh
ID="${id_name}"
MYSQLPASS="${msql_rootpass}"
PUBLICKEY=""
TMPDIR="/tmp/"
CLOUDDIR="${backup_path}"

#Folders to backup
${DIRS}
EOF

echo "Please edit /usr/local/backup-settings/options.sh and add the paths to be backed up."

echo "Adding daily cronjob"
cp backup.sh /usr/bin

(crontab -l ; echo "@daily bash /usr/bin/backup.sh") | crontab -
