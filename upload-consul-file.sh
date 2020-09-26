#!/bin/bash

file="$1"
filename=$(basename $file)
app=${filename%.*}
curl  --output /dev/null -sX PUT --data-binary @$file http://$CONSUL_URL:$CONSUL_PORT/v1/kv/config/$app/data
echo "   $file uploaded to Consul"
