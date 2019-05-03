#!/usr/bin/env bash

set -e
set -u

###
### Globals
###

# Path to scripts to source
FUNC_DIR="/scripts/func.d"
# Supervisord config directory
MONIT_CONFD="/etc/monit/conf.d"
RUNTIME_CONFIG_DIR="/scripts/pre-init.d"

###
### Source libs
###
init="$( find "${FUNC_DIR}" -name '*.sh' -type f | sort -u )"
for f in ${init}; do
	. "${f}"
done

#############################################################
## Entry Point
#############################################################

###
### Set Debug level
###
DEBUG_LEVEL="$( env_get "DEBUG_ENTRYPOINT" "0" )"
log "info" "Debug level: ${DEBUG_LEVEL}" "${DEBUG_LEVEL}"

###
### Runtime script
###
exec_script="$( find "${RUNTIME_CONFIG_DIR}" -name '*.sh' -type f | sort -u )"
for f in ${exec_script}; do
	. "${f}"
done

###
### Validate socat port forwards
###
if ! port_forward_validate "FORWARD_PORTS_TO_LOCALHOST" "${DEBUG_LEVEL}"; then
	exit 1
fi

##
## Supervisor: socat
##
for line in $( port_forward_get_lines "FORWARD_PORTS_TO_LOCALHOST" ); do
	lport="$( port_forward_get_lport "${line}" )"
	rhost="$( port_forward_get_rhost "${line}" )"
	rport="$( port_forward_get_rport "${line}" )"
	monit_add_service \
		"socat-${lport}-${rhost}-${rport}" \
		"matching \"tcp-listen:${lport},reuseaddr,fork tcp:${rhost}:${rport}\"" \
		"/usr/bin/socat tcp-listen:${lport},reuseaddr,fork tcp:${rhost}:${rport}" \
		"/usr/bin/socat tcp-listen:${lport},reuseaddr,fork" \
		"root" \
		"${MONIT_CONFD}" \
		"if does not exist" \
		"${DEBUG_LEVEL}"
done

###
### Supervisor: php-fpm
###
monit_add_service \
	"php-fpm" \
	"pidfile /usr/local/var/run/php-fpm.pid" \
	"/usr/local/sbin/php-fpm" \
	"/bin/bash -c echo 'php-fpm stop'" \
	"root" \
	"${MONIT_CONFD}" \
	"if failed host 127.0.0.1 port 9000 type tcp" \
	"${DEBUG_LEVEL}"

###
###
### Startup
###
/usr/bin/monit -t
log "info" "Starting monit" "${DEBUG_LEVEL}"
exec /usr/bin/monit -Ic /etc/monitrc
