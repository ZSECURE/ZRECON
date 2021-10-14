#!/bin/bash
# Bash script to scan a network or range for defined web ports and examine the sreenshot results through HTML.
# example - ./png2html.sh 80,443,8443,9443 192.168.10.0/24 nmap_output

port=$1
target=$2
nmap_output_file=$3

sudo nmap -A -p$port --open $target -oG $nmap_output_file

ports=$(echo $port | sed 's/,/\\|/g') 

for ip in $(cat $nmap_output_file | grep "$ports" | grep -v "Nmap" | awk '{print $2}'); do  cutycapt --url=$ip --out=$ip.png ;done

echo '<!DOCTYPE html><html lang="en"><head><title>Screenshots</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>p { color: red; text-align: center;}h1 { color: black; text-align: center;}</style></head><body>' > web.html

echo "<h1> Screenshots </h1>" >> web.html

ls -l *.png  |  awk -F " " '{ print "<p>" $9":\n<br><img src=\""$9"\" width=600></p><br>"}' >> web.html

echo "</body></html>" >> web.html

firefox web.html
