#!/bin/bash

extaddr=$(dig @resolver1.opendns.com myip.opendns.com +short)
echo "The external IP address is $extaddr (from dig)"
previousIp=`cat ip.log`

echo "Previous IP: $previousIp"

function updateCloudflare(){
        curl --location --request PUT "https://api.cloudflare.com/client/v4/zones/$1/dns_records/$2" \
                --header "Authorization: Bearer $3" \
                --header 'Content-Type: application/json' \
                --data-raw "$4"

}


if [ "$previousIp" = "$extaddr" ]; then
        echo "IP is not changed."
else
        echo "IP is changed"
        echo "Save current IP"
        echo "$extaddr" > ip.log

        token='' // Get Token from your Account
        zoneId='' // Provide Zone ID
        recordId='' // Provide Record ID
        recordType='A'
        recordName='' // Replace with your domain which need DNS updating
        recordContent="$extaddr"
        body="{
            \"type\": \"$recordType\",
            \"name\": \"$recordName\",
            \"content\": \"$extaddr\",
            \"ttl\": 3600,
            \"proxied\": false
        }"

        echo "$body"
        echo "Update Cloudflare"
        updateCloudflare "$zoneId" "$recordId" "$token" "$body"
fi
