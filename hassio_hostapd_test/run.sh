#!/bin/bash


TMP_DIR="/tmp"
PID_FILE="$TMP_DIR/netscan.pip"
RSLT_FILE="$TMP_DIR/clients.tmp"
CLIENTS_DIR="/config/custom_components/netscan"
CLIENTS_FILE="clients.json"

CONFIG_PATH="/data/options.json"
MQTT_SERVER=$(jq --raw-output ".mqtt_server" $CONFIG_PATH)
MQTT_TOPIC=$(jq --raw-output ".mqtt_topic" $CONFIG_PATH)

required_vars=(MQTT_SERVER MQTT_TOPIC)

for required_var in "${required_vars[@]}"; do
	if [[ -z ${!required_var} ]]; then
		error=1
		echo >&2 "Error: $required_var env variable not set."
	fi
done

trap 'term_handler' SIGTERM

term_handler(){
	if [ -f "$PID_FILE" ]; then
		rm "$PID_FILE"
	fi
	
	if [ -f "$RSLT_FILE" ]; then
		rm "$RSLT_FILE"
	fi
	
	echo "Stopping..."
	exit 0
}

looper() {
	echo "Starting scan"
	if [[ ! -f "$PID_FILE" ]] || [[ ! -f "$RSLT_FILE" ]]; then
		echo $$ > "$PID_FILE"
		echo -n '' > "$RSLT_FILE"
		/usr/sbin/fping -A -d -a -q -g -a -i 1 -r 0 192.168.1.0/24 > "$RSLT_FILE" 2>&1
	else
		error=1
		echo >&2 "Error: program is running"
	fi

	declare -a CLIENTS=()

	if [ -f "$RSLT_FILE" ]; then
		while IFS= read -r line 
		do
			CLIENTS+=($(echo "$line" | awk '{print $1}'))
		done < "$RSLT_FILE"
		rm "$RSLT_FILE"
	else
		if [ -f "$PID_FILE" ]; then
		  rm "$PID_FILE"
		fi
		error=1
		echo >&2 "Error not file found"
	fi

	JSON_STR=""

	if [ $CLIENTS ]; then
		for i in ${!CLIENTS[@]}; do
		  JSON_STR+='"'${CLIENTS[$i]}'"'
		done
	else
		if [ -f "$PID_FILE" ]; then
		  rm "$PID_FILE"
		fi
		error=1
		echo >&2 "Error: no clients found"
	fi

	if [ ! -z "$JSON_STR" ]; then
		MSG_STR=$(echo "{\"clients\":[$JSON_STR]}" | sed -e 's/""/","/g')
		/usr/bin/mosquitto_pub -h "$MQTT_SERVER" -t "$MQTT_TOPIC" -m "$MSG_STR"
		if [[ ! -d "$CLIENTS_DIR" ]]; then
		  /bin/mkdir "$CLIENTS_DIR"
		  if [[ ! -d "$CLIENTS_DIR" ]]; then
			error=1
			echo >&2 "Error: failed to create directory"
		  fi
		fi
		if [[ -n $error ]]; then
		  exit 1
		fi
		if [[ -d "$CLIENTS_DIR" ]]; then
			echo -n "$MSG_STR" > "$CLIENTS_DIR/$CLIENTS_FILE"
		else
			error=1
			echo >&2 "Error: failed to create clients file"
		fi
	else
		if [ -f "$PID_FILE" ]; then
		  rm "$PID_FILE"
		fi
		error=1
		echo >&2 "Error not file found"
	fi

	if [[ -n $error ]]; then
		if [ -f "$PID_FILE" ]; then
			rm "$PID_FILE"
		fi
		exit 1
	fi

	echo "finished scanning"
	
	if [ -f "$PID_FILE" ]; then
		rm "$PID_FILE"
	fi
	
	if [ -f "$RSLT_FILE" ]; then
		rm "$RSLT_FILE"
	fi
}

if [[ -n $error ]]; then
	exit 1
else
	while [ -z $error ]
	do
		looper
		sleep 5m		
	done
fi
