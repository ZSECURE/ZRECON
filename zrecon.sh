#!/bin/bash
#
# Recon shell script
# Example ./zrecon.sh 8.8.8.8 output.txt
# Debug with `bash -x ./zrecon.sh 192.168.10.254 output.txt`

G_TARGET=$1
G_OUTPUT=$2
G_THREADS="5"
G_WORDLIST="/opt/SecLists/Discovery/Web-Content/raft-small-words.txt"

function ns_lookup {
  nslookup ${G_TARGET} | tee ${G_OUTPUT}
  }

function trace_route {
  traceroute -m 10 ${G_TARGET} | tee -a ${G_OUTPUT}
  }

function nmap_web {
  nmap -p 80,443 ${G_TARGET} -oN nmap-web.txt
}

function nmapinitial {
  nmap -T3 -sT ${G_TARGET} -oN nmap-initial.txt 
  }

function nmapallports {
  nmap -sS -T3 -p- ${G_TARGET} -oN nmap-allports.txt
  }

function ssl_scan {
  sslscan ${G_TARGET} | tee -a ${G_OUTPUT}
  }

function headers80 {
  curl -I http://${G_TARGET} | tee -a ${G_OUTPUT}
  }

function headers443 {
  curl -k -I https://${G_TARGET} | tee -a ${G_OUTPUT}
  }

function nikto80 {
  nikto -h $G_TARGET | tee -a ${G_OUTPUT}
  }

function nikto443 {
  nikto -h $G_TARGET -ssl | tee -a ${G_OUTPUT}
  }

function gobuster80 {
  gobuster dir -u http://${G_TARGET} -w ${G_WORDLIST} -t ${G_THREADS} -o gobuster80.txt
  } 

function gobuster443 {
  gobuster dir -u https://${G_TARGET} -w ${G_WORDLIST} -t ${G_THREADS} -o gobuster443.txt
  }

function web_checks80 {
  if [ "$web80" -eq "80" ]; then 
    headers80
    nikto80
    gobuster80
  else
    echo "Port 80 is not open!"
  fi
}

function web_checks443 {
  if [ "$web443" -eq "443" ]; then
    headers443
    ssl_scan
    nikto443
  else
    echo "Port 443 is not open!"
  fi
}

# Main body of the shell script starts here.

ns_lookup
#trace_route
nmap_web
nmapinitial
nmapallports

# Web Enumeration

web80=$(cat nmap-web.txt | grep open | grep '80' | awk -F "/" {'print$1'})
web443=$(cat nmap-web.txt | grep open | grep '443' | awk -F "/" {'print$1'})

web_checks80
web_checks443


# Exit with an explicit exit status.
exit 0
