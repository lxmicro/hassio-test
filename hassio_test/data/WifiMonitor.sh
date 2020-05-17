#!/bin/sh

VARS=""
VARS="${VARS} PidFile"
VARS="${VARS} RslFile"
VARS="${VARS} LogFile"
VARS="${VARS} PidDir"
VARS="${VARS} RslDir"
VARS="${VARS} LogDir"
VARS="${VARS} MonWlan"

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
ln=$(echo ${#me})
fin=$(echo $me | cut -c 2-$(($ln-3)))
ini=$(echo $me | cut -c 1-1)
proc="\"[$ini]$fin\""
nam=$(echo $ini$fin)

CurDir=$(echo $PWD)
CONF="$CurDir/$nam.conf"

if [ -f "$CONF" ]; then
  . "$CONF"
else
  CONF="/etc/default/$nam.conf"
  if [ -f "$CONF" ]; then
    . "$CONF"
  else
    CONF="/etc/wifimonitor/$nam.conf"
    if [ -f "$CONF" ]; then
    . "$CONF"
    else
      exit 1
    fi
  fi
fi

cmd=$(eval "ps | grep $proc")
rslt=$(echo $cmd | awk '{print $1}')

if [ -z "$rslt" ]; then
  exit 1
fi

if [ "$rslt == $$" ]; then
  if [ ! -z "$nam" ];  then
    PidFile=$(echo "$PidDir$nam.pid")
    RslFile=$(echo "$RslDir$nam.js")
    LogFile=$(echo "$LogDir$nam.log")
    MonWlan=$(echo "$MonWlan")
  else
    exit 1
  fi
else
  exit 1
fi

for VAR in ${VARS}; do
  ConFile=$(eval echo $"${VAR}")
  if [ -z "$ConFile" ]; then
    exit 1
  fi
done

echo 'iniciando programa' > $LogFile

if [ -f "$PidFile" ]; then
  echo "el archivo $PidFile existe" >> $LogFile
  exit 1
fi

echo $$ > $PidFile

while [ -f "$PidFile" ]
  do
    clients=$(/sbin/ip neigh | grep ${MonWlan} | awk '{ if(match($0,/REACHABLE/)){ printf "{\"ip\":\"%s\",\"mac\":\"%s\"}", $1, $5; }}')
    json=$(echo $clients | sed -e 's/}{/\},\{/g')
    echo "{\"clients\":[$json]}" > $RslFile
    sleep 1
  done

if [ -f "$PidFile" ]; then
  rm $PidFile
fi

echo '' > $LogFile