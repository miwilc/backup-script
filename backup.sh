#!/bin/bash
#
# Backup Script
#   Author: Andre Bongon (1Conan)
#   Copyright (c) 2016 Andre Bongon
#   Licensed under MIT License
#

source ~/backup-settings/options.sh

if [ "${ENPASS}" == true ]; then
	if [ ! -f "${PUBLICKEY}" ]; then
		echo "PUBLICKEY IS REQUIRED IF ENPASS IS ENABLED!"
		exit 1
	fi
fi

mysqlbackup() {
	mysqldump -uroot -p"${MYSQLPASS}" --all-databases > ${TMPDIR}my.sql
	tar -cvf "${TMPDIR}mysql.tar" "${TMPDIR}my.sql"  
	mv "${TMPDIR}mysql.tar" "${TMPDIR}backup"
}

mkdir "${TMPDIR}backup"

for i in "${DIR[@]}"; do
	FILENAME=$(echo "${i}" | sed 's/^.//' | sed 's/\//./g')
	tar -cvf "${TMPDIR}${FILENAME}.tar" "$i"
	mv "${TMPDIR}${FILENAME}.tar" "${TMPDIR}backup"
done

if [ "$MYSQLPASS" != "" ]; then
	mysqlbackup
fi

FILENAME=$(date +"%Y_%m_%d-%H_%M")
PASS="$(openssl rand -hex 32 | head -c 16)$(openssl rand -hex 32 | tail -c 16)"

if [ "$ENPASS" == false ]; then
	7z a -y -sdel -mm=BZip2 "${TMPDIR}backup/files.7z" "${TMPDIR}backup/*.tar"
elif [ "$ENPASS" == true ]; then
	7z a -y -sdel -mm=BZip2 -p"${PASS}" "${TMPDIR}backup/files.7z" "${TMPDIR}backup/*.tar"
fi

if [ "$ENPASS" == true ]; then
	echo "${PASS}" > "${TMPDIR}backup/key.bin"
	openssl rsautl -encrypt -inkey "${PUBLICKEY}" -pubin -in "${TMPDIR}backup/key.bin" -out "${TMPDIR}backup/key.bin.enc"
	rm -rf "${TMPDIR}backup/key.bin"
fi

tar -cvf "${TMPDIR}${ID}-${FILENAME}.tar" "${TMPDIR}backup/"
rm -rf "${TMPDIR}backup"
mv "${TMPDIR}${ID}-${FILENAME}.tar" "${CLOUDDIR}"
find "${CLOUDDIR}" -name "*.tar" -type f -mtime +30 -print -delete >> ~/backup-settings/log-${FILENAME}.log
