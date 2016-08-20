#Server Identifier
ID=""

#MySQL root pass
MYSQLPASS=""

#Encrypt 7z archives with a pass. 
#You can enable or disable it.
ENPASS=false

#Temporary directory. Change if you want. INCLUDE TRAILING SLASH
TMPDIR="/tmp/"

#Where the cloud storage platform is mounted.
#You can add subfolder path to move it there.
CLOUDDIR="/mnt/googledrive/"

#Just add more directories if you want. You should already know how to add
#or remove more. P.S. Include trailing slash
DIR[0]="/root/"
DIR[1]="/home/"
DIR[2]="/usr/local/nginx/"
