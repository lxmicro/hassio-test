#!/usr/bin/env bashio

for OPTION in $(bashio::config 'hostapd|keys'); do
    NAME=$(bashio::config "hostapd[${OPTION}].name")
    PASS=$(bashio::config "hostapd[${OPTION}].passphrase")
    CHANNEL=$(bashio::config "hostapd[${OPTION}].channel")
    INTERFACE=$(bashio::config "hostapd[${OPTION}].hostad_interface")
    BROADCAST=$(bashio::config "hostapd[${OPTION}].hostad_ip")
    COUNTRY="$(bashio::config "hostapd[${OPTION}].country_code")"
    MODE="$(bashio::config "hostapd[${OPTION}].hw_mode")"
    {
        echo "country_code=${COUNTRY}"
        echo "interface=${INTERFACE}"
        echo "ssid=${NAME}"
        echo "hw_mode=${MODE}"
        echo "channel=${CHANNEL}"
        echo "macaddr_acl=0"
        echo "auth_algs=1"
        echo "ignore_broadcast_ssid=0"
        echo "wpa=2"
        echo "wpa_passphrase=${PASS}"
        echo "wpa_key_mgmt=WPA-PSK"
        echo "wpa_pairwise=TKIP"
        echo "rsn_pairwise=CCMP"
    } > "${HOSTAP_CONFIG}"
done

echo "valor: $HOSTAP_CONFIG"
bashio::log.info $HOSTAP_CONFIG

exit 0

function stop_addon(){
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


function TABLE_UP_RULE_01(){
  local cmd=$(iptables-save | grep -- "-A POSTROUTING -o eth0 -j MASQUERADE" | awk '{ if ( $0 ){ print "1" } }')
  if [ ! -z "$cmd" ]; then
     echo 0
     return 0
  else
     su -s /bin/sh -c "/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" root
     if [ "$?" -ne 0 ]; then
       echo 1
       return 1
     else
       echo 0
       return 0
     fi
  fi
  echo 1
  return 1
}


function TABLE_UP_RULE_02(){
  local cmd=$(iptables-save | grep -- "-A FORWARD -i eth0 -o $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT" | awk '{ if ( $0 ){ print "1" } }')
  if [ ! -z "$cmd" ]; then
     echo 0
     return 0
  else
     su -s /bin/sh -c "/sbin/iptables -A FORWARD -i eth0 -o $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT" root
     if [ "$?" -ne 0 ]; then
       echo 1
       return 1
     else
       echo 0
       return 0
     fi
  fi
  echo 1
  return 1
}


function TABLE_UP_RULE_03(){
  local cmd=$(iptables-save | grep -- "-A FORWARD -i $INTERFACE -o eth0 -j ACCEPT" | awk '{ if ( $0 ){ print "1" } }')
  if [ ! -z "$cmd" ]; then
     echo 0
     return 0
  else
     su -s /bin/sh -c "/sbin/iptables -A FORWARD -i $INTERFACE -o eth0 -j ACCEPT" root
     if [ "$?" -ne 0 ]; then
       echo 1
       return 1
     else
       echo 0
       return 0
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

bashio::log.info "Creating iptables rules ..."

if [ "$(TABLE_UP_RULE_01)" -ne 0 ]; then
  bashio::log.info "Error: in iptables rule 1"
  exit 1
fi

if [ "$(TABLE_UP_RULE_02)" -ne 0 ]; then
  bashio::log.info "Error: in iptables rule 2"
  exit 1
fi

if [ "$(TABLE_UP_RULE_03)" -ne 0 ]; then
  bashio::log.info "Error: in iptables rule 3"
  exit 1
fi

bashio::log.info "Ok"