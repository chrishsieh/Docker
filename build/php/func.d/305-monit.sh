#!/usr/bin/env bash

set -e
set -u
set -o pipefail


############################################################
# Functions
############################################################

###
### Add service with pid to monit
###
monit_add_service() {
    local name="${1}"
    local searchrule="${2}"
    local commandstart="${3}"
    local commandstop="${4}"
    local user="${5}"
    local confd="${6}"
    local checkrule="${7}"
    local debug="${8}"

    if [ ! -d "${confd}" ]; then
        run "mkdir -p ${confd}" "${debug}"
    fi

    log "info" "Enabling '${name}' to be started by monit" "${debug}"
    # Add services
    {
        echo "check process ${name} with ${searchrule}"
        echo "    start program = \"${commandstart}\""
        echo "        as uid ${user} and gid ${user}"
        echo "        with timeout 60 seconds"
        echo "    stop program = \"${commandstop}\""
        echo "        as uid ${user} and gid ${user}"
        echo "    ${checkrule} for 3 cycles then restart"
    } > "${confd}/${name}.cfg"
}
