#!/bin/bash

if [ $MASTER_ACL_TOKEN = $CLIENT_ACL_TOKEN ]; then
    echo "client and master acl token cannot be equal"
    exit 1
fi

# To use outside of docker, set the following environment variables
# export INIT_SLEEP_SECONDS=0;export CONFIG_MODE=filesystem;export CONFIG_DIR=config/;export CONSUL_URL=localhost;export CONSUL_PORT=8500
sleep $INIT_SLEEP_SECONDS

echo "setting ACL settings"
echo "----------------------------------------------------------------------"

cat jhi-acl.json | sed s/to-change-in-production-client/$CLIENT_ACL_TOKEN/ | curl -sX PUT -d "@-" http://$CONSUL_URL:$CONSUL_PORT/v1/acl/create?token=$MASTER_ACL_TOKEN

echo "----------------------------------------------------------------------
    Starting Consul Config Loader in $CONFIG_MODE mode"

function loadPropertiesFilesIntoConsul {
  for file in $CONFIG_DIR/*.yml
	do
	  filename=$(basename $file)
	  app=${filename%%.*}
	  curl -sX PUT --data-binary @$file http://$CONSUL_URL:$CONSUL_PORT/v1/kv/config/$app/data?token=$MASTER_ACL_TOKEN  # > /dev/null
	done
  echo "   Consul Config reloaded"
}


if [[ "$CONFIG_MODE" == "filesystem" ]]; then
	echo "----------------------------------------------------------------------
    Loading YAML config files in Consul K/V Store from the filesystem
    Add or edit properties files in '$CONFIG_DIR' to have them
    automatically reloaded into Consul
    Consul UI: http://$CONSUL_URL:$CONSUL_PORT/ui/#/dc1/kv/config/
----------------------------------------------------------------------"
    # Load the files for the first time
    loadPropertiesFilesIntoConsul
	# Reload the files when there is a file change
	inotifywait -q -m --format '%f' -e close_write $CONFIG_DIR/ | while read
	do
		loadPropertiesFilesIntoConsul
	done
fi

if [[ "$CONFIG_MODE" == "git" ]]; then
	echo "----------------------------------------------------------------------
   Loading configuration in Consul K/V Store from a git repository using git2consul"
	printf "      git_url          : "
  cat $CONFIG_DIR/git2consul.json | jq  '.repos[0].url'
	printf "      branch(es)       : "
  cat $CONFIG_DIR/git2consul.json | jq  '.repos[0].branches[]'
	printf "      source_root      : "
  cat $CONFIG_DIR/git2consul.json | jq  '.repos[0].source_root'
	printf "      polling_interval : "
  cat $CONFIG_DIR/git2consul.json | jq  '.repos[0].hooks[].interval'

	echo "   Consul UI: http://$CONSUL_URL:$CONSUL_PORT/ui/#/dc1/kv/config/
----------------------------------------------------------------------"
	git2consul --config-file $CONFIG_DIR/git2consul.json -e $CONSUL_URL -p $CONSUL_PORT
fi
