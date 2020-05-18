#!/usr/bin/env bashio

set -e

INTERFACE="dummy0"
IP="10.0.0.1"
CONFIG="/etc/dhcpd.conf"
LEASES="/data/dhcpd.lease"

INI_CMDS_1="ifconfig $INTERFACE | awk '{ if(match(\$0,/$INTERFACE/)){ print 0; } }'"
INI_CMDS_2="ip link delete $INTERFACE 2>/dev/null"

STR_CMDS_1="ip link add $INTERFACE type dummy 2>/dev/null"
STR_CMDS_2="ip link set $INTERFACE multicast on 2>/dev/null"
STR_CMDS_3="ip addr add $IP/24 dev $INTERFACE 2>/dev/null"
STR_CMDS_4="ip link set $INTERFACE up 2>/dev/null"

stop_addon(){
  bashio::log.info "Removing Network Interface ..."
  local cmd=$(echo "$INI_CMDS_2")
  local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
  if [ "$r" == 0 ]; then
    echo "Stopped Ok"
    exit 0
  else
    echo "Error"
    exit 1
  fi
}

function cmd_init() {
  local r=$(eval "$INI_CMDS_1")
  if [ "$r" == 0 ]; then
    bashio::log.info "$INTERFACE exists, try to remove ..."
    local cmd=$(echo "$INI_CMDS_2")
    local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
    if [ "$r" == 0 ]; then
      bashio::log.info "Ok: $INTERFACE removed ..."
      echo 0
      return 0
    fi
  else
    echo 0
    return 0
  fi
  echo 1
  return 1
}

function create_interface(){
  local cmd=$(echo "$STR_CMDS_1")
  local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
  if [ "$r" == 0 ]; then
    local cmd=$(echo "$STR_CMDS_2")
    local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
    if [ "$r" == 0 ]; then
      local cmd=$(echo "$STR_CMDS_3")
      local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
      if [ "$r" == 0 ]; then
        local cmd=$(echo "$STR_CMDS_4")
        local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
        if [ "$r" == 0 ]; then
          echo 0
          return 0
        fi
      fi
    fi
  fi
  echo 1
  return 1
}

trap "stop_addon" SIGTERM SIGHUP
bashio::log.info "Starting ..."

if [ "$(cmd_init)" -ne 0 ]; then
  bashio::log.info "Error: interface exists"
  exit 1
fi

if [ "$(create_interface)" -ne 0 ]; then
  bashio::log.info "Error: unable to start interface"
  exit 1
fi

bashio::log.info "Ok"
exit 0