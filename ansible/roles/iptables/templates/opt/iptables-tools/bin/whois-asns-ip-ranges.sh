#!/bin/bash

INPUT=$1

# extract IP address from input
IP=`echo $INPUT | cut -d ' ' -f1`

if [ -z "$IP" ]
then
    exit
fi

ASN=$(whois -h whois.radb.net $IP | grep origin: | awk '{print $NF}' | head -1)
whois -h whois.radb.net -- "-i origin -T route $ASN" | grep -w "route:" | awk '{print $NF}' | sort -n
