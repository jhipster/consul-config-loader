#!/bin/bash

file="$1"
filename=$(basename $file)
app=${filename%.*}
if [[ "$ENABLE_SPRING" == "true" ]]; then
  curl  --output /dev/null -sX PUT --data-binary @$file http://$CONSUL_URL:$CONSUL_PORT/v1/kv/config/$app/data
  echo "   $file uploaded to Consul in Spring mode"
fi

if [[ "$ENABLE_MICRONAUT" == "true" ]]; then
  curl  --output /dev/null -sX PUT --data-binary @$file http://$CONSUL_URL:$CONSUL_PORT/v1/kv/config/$app
  echo "   $file uploaded to Consul in Micronaut mode"
fi
