#!/bin/bash

# SIGTERM-handler this funciton will be executed when the container receives the SIGTERM signal (when stopping)

term_handler(){
	echo "Stopping..."
	exit 0
}

# Setup signal handlers
trap 'term_handler' SIGTERM

echo "Starting..."

CONFIG_PATH=/data/options.json

MQTT_SERVER=$(jq --raw-output ".mqtt_server" $CONFIG_PATH)
required_vars=(MQTT_SERVER)
for required_var in "${required_vars[@]}"; do
    if [[ -z ${!required_var} ]]; then
        error=1
        echo >&2 "Error: $required_var env variable not set."
    fi
done

if [[ -n $error ]]; then
    exit 1
fi

echo "Starting HostAP daemon ..."
hostapd -d /hostapd.conf & wait ${!}