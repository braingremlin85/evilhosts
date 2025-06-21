#!/bin/bash
# EVILHOSTS
# Generate a hosts file from internet lists of malicious url
#
# 	Cronjobs for DD-WRT hosts list import
# 	======================================
#	0 4 * * 0 wget http://apollo.local/hosts.txt -O /tmp/hosts.add/customhosts
#	10 4 * * 0 service dnsmasq restart

# CONFIG START
WORKING_DIR="/volume4/media/script/evilhosts/"
EXPORTFILE="/volume1/web/hosts.txt"
EXCLUDESFILE="exclude.list"

HOSTSLISTS=( 
	"http://someonewhocares.org/hosts/hosts"
	#"http://www.malwaredomainlist.com/hostslist/hosts.txt" blank list atm
	"https://urlhaus.abuse.ch/downloads/hostfile/"
	"https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/native.winoffice.txt"
) 

# CONFIG END

ERRCOUNT=0

cd $WORKING_DIR

rm $EXPORTFILE

touch $EXPORTFILE

mkdir -p 'lists'

mapfile -t EXCLUDELIST < "$EXCLUDESFILE" 

for i in "${HOSTSLISTS[@]}" 
do 
	FILENAME=$(echo "$i" | awk -F/ '{print $3}') #extract domain name to name file

	printf "Downloading $FILENAME...\n"
	#wget $i -O "lists/"$FILENAME -q
	
	if [ $? -eq 0 ]; then
		printf "$FILENAME downloaded successfully\n"
		logger "EVILHOSTS: $FILENAME downloaded successfully\n"
	else
		printf "Download of $FILENAME failed\n"
		logger "EVILHOSTS: Download of $FILENAME failed"
		((ERRCOUNT++))
	fi
	
	IFS='|' ;sed -E "/${EXCLUDELIST[*]}/d;/^\s*#/d;/^[[:space:]]*$/d" "lists/$FILENAME" >> $EXPORTFILE

done
sort -u -o $EXPORTFILE $EXPORTFILE

#headers for hosts file
sed -i "1 i\#$(date)" $EXPORTFILE
sed -i "2 i\#evilhosts hosts file generator by braingremlin" $EXPORTFILE

if [ $? -eq 0 ]; then
	printf "$EXPORTFILE exported successfully\n"
	logger "EVILHOSTS: $EXPORTFILE exported successfully\n"
else
	printf "Export of $FILENAME failed\n"
	logger "EVILHOSTS: Export of $FILENAME failed"
	((ERRCOUNT++))
fi

if [ $ERRCOUNT -eq 0 ]; then
	#succeded
	printf "$EXPORTFILE exported without errors\n"
	logger "EVILHOSTS: $EXPORTFILE exported without errors"
else
	#errors
	printf "EVILHOSTS parsing throw $ERRCOUNT error\n"
	logger "EVILHOSTS parsing throw $ERRCOUNT error"
fi