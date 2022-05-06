braingremlin's EVILHOSTS
========================
Generate a hosts file from internet lists of malicious url

Cronjobs for DD-WRT hosts list import
======================================
0 4 * * 0 wget http://yourwebserver/hosts.txt -O /tmp/hosts.add/customhosts
10 4 * * 0 service dnsmasq restart