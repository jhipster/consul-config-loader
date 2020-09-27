#!/bin/bash

# To use outside of docker, set the following environment variables
# export INIT_SLEEP_SECONDS=0;export CONFIG_MODE=filesystem;export CONFIG_DIR=config/;export CONSUL_URL=localhost;export CONSUL_PORT=8500
sleep $INIT_SLEEP_SECONDS

echo "----------------------------------------------------------------------
    Starting Consul Config Loader in $CONFIG_MODE mode"

function loadPropertiesFilesIntoConsul {
  for file in $CONFIG_DIR/*."${CONFIG_FORMAT:-yml}"
	do
	  /upload-consul-file.sh $file
	done
  echo "   Consul Config reloaded"
}


if [[ "$CONFIG_MODE" == "filesystem" ]]; then
	echo "----------------------------------------------------------------------
    Loading config files in Consul K/V Store from the filesystem
    Add or edit properties files in '$CONFIG_DIR' to have them
    automatically reloaded into Consul
    Consul UI: http://$CONSUL_URL:$CONSUL_PORT/ui/#/dc1/kv/config/
----------------------------------------------------------------------"

  # Wait until the consul agent is up
	until $(curl --output /dev/null --silent --fail http://$CONSUL_URL:$CONSUL_PORT/v1/health/state/critical); do
    echo 'Trying to contact the consul agent...'
		sleep 1
	done

  # Load the files for the first time
  loadPropertiesFilesIntoConsul

	# Reload the files when there is a file change
    simplywatch -g "$CONFIG_DIR/**" -x "/upload-consul-file.sh {{path}}"

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
