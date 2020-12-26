#!/bin/bash

TMP_DIR="/tmp"
PID_FILE="$TMP_DIR/netscan.pip"
RSLT_FILE="$TMP_DIR/clients.tmp"

if [[ ! -f "$PID_FILE" ]] || [[ ! -f "$RSLT_FILE" ]]; then
  echo $$ > "$PID_FILE"
  echo -n '' > "$RSLT_FILE"
  /usr/sbin/fping -A -d -a -q -g -a -i 1 -r 0 192.168.1.0/24 > "$RSLT_FILE" 2>&1
else
  echo "program is running" >&2
  exit 1
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
  echo "file not found" >&2
  exit 1
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
  echo "not clients found" >&2
  exit 1
fi

if [ ! -z "$JSON_STR" ]; then
  MSG_STR=$(echo "{\"clients\":[$JSON_STR]}" | sed -e 's/""/","/g')
  /usr/bin/mosquitto_pub -h 192.168.1.179 -t PcControl/network/clients -m "$MSG_STR"  
else
  if [ -f "$PID_FILE" ]; then
    rm "$PID_FILE"
  fi
  echo "not clients" >&2
  exit 1
fi

if [ -f "$PID_FILE" ]; then
  rm "$PID_FILE"
fi

exit 0