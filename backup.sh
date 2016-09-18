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

deleteoldbackups() {
	true;
}

mysqlbackup() {
	mysqldump -uroot -p"${MYSQLPASS}" --all-databases > ${TMPDIR}my.sql
	tar -cvf "${TMPDIR}mysql.tar" "${TMPDIR}my.sql"
  
	if [ "$ENPASS" == false ]; then
		7z a -y -sdel -mm=BZip2 "${TMPDIR}mysql.tar.7z" "${TMPDIR}mysql.tar"
	elif [ "$ENPASS" == true ]; then
		7z 7z a -y -sdel -mm=BZip2 -p"${PASS}" "${TMPDIR}mysql.tar.7z" "${TMPDIR}mysql.tar"
	fi
  
	mv "${TMPDIR}mysql.tar.7z" "${TMPDIR}backup"
}

if [ "$ENPASS" == true ]; then
	PASS="$(openssl rand -hex 32 | head -c 16)$(openssl rand -hex 32 | tail -c 16)"
fi

mkdir "${TMPDIR}backup"

for i in "${DIR[@]}"; do
	FILENAME=$(echo "${i}" | sed 's/^.//' | sed 's/\//./g')
	tar -cvf "${TMPDIR}${FILENAME}.tar" "$i"
	if [ "$ENPASS" == false ]; then
		7z a -y -sdel -mm=BZip2 "${TMPDIR}${FILENAME}.tar.7z" "${TMPDIR}${FILENAME}.tar"
	elif [ "$ENPASS" == true ]; then
		7z a -y -sdel -mm=BZip2 -p"${PASS}" "${TMPDIR}${FILENAME}.tar.7z" "${TMPDIR}${FILENAME}.tar"
	fi
	mv "${TMPDIR}${FILENAME}.tar.7z" "${TMPDIR}backup"
done
if [ "$MYSQLPASS" != "" ]; then
	mysqlbackup
fi

FILENAME=$(date +"%m-%d-%y")

if [ "$ENPASS" == true ]; then
	echo "${PASS}" > "${TMPDIR}backup/key.bin"
	openssl rsautl -encrypt -inkey "${PUBLICKEY}" -pubin -in "${TMPDIR}backup/key.bin" -out "${TMPDIR}backup/key.bin.enc"
fi

7z a -y -sdel -mm=BZip2 "${TMPDIR}${ID}-${FILENAME}.tar.7z" "${TMPDIR}backup/"

mv "${TMPDIR}${ID}-${FILENAME}.tar.7z" "${CLOUDDIR}"

deleteoldbackups
