#!/bin/bash

set -e

INTERFACE="dummy0"
IP="10.0.0.0"

INI_CMDS_1="ifconfig $INTERFACE | awk '{ if(match(\$0,/$INTERFACE/)){ print 0; } }'"
INI_CMDS_2="ip link delete $INTERFACE 2>/dev/null"

STR_CMDS_1="ip link add $INTERFACE type dummy 2>/dev/null"
STR_CMDS_2="ip link set $INTERFACE multicast on 2>/dev/null"
STR_CMDS_3="ip addr add $IP/24 dev $INTERFACE 2>/dev/null"
STR_CMDS_4="ip link set $INTERFACE up 2>/dev/null"

term_handler(){
  echo "Stopping..."
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

function cmd_init {
  local r=$(eval "$INI_CMDS_1")
  if [ "$r" == 0 ]; then
    local cmd=$(echo "$INI_CMDS_2")
    local r=$(awk -v cmd="$cmd" 'BEGIN {rst=system(cmd); print rst}')
    if [ "$r" == 0 ]; then
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

trap 'term_handler' SIGTERM

if [ "$(cmd_init)" -ne 0 ]; then
  exit 1
fi

if [ "$(create_interface)" -ne 0 ]; then
  exit 1
fi

echo "finalizado"
exit 0
