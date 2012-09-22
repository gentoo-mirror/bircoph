#!/sbin/runscript
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

. /etc/conf.d/torque
PBS_SERVER_HOME="$(. /etc/env.d/25torque; echo ${PBS_SERVER_HOME})"

depend() {
    need net
    after pbs_server
    after pbs_sched
    after logger
}

checkconfig() {
    for i in "server_name" "mom_priv/config"; do
        if [ ! -e ${PBS_SERVER_HOME}/${i} ]; then
            eerror "Missing config file ${PBS_SERVER_HOME}/${i}"
            return 1
        fi
    done
}

start() {
    checkconfig || return 1

    # check for a stale lock file, otherwise pbs_mom may fail to
    # start, see unicluster # 75 bug
    local utime unchtime
    if [[ -f ${PBS_SERVER_HOME}/torque/mom_priv/mom.lock ]]; then
        utime=$( gawk -F "[ .]" '{ print $1 }' /proc/uptime) 
        unchtime=$(( $(date +%s) - $(stat -c %Y ${PBS_SERVER_HOME}/mom_priv/mom.lock) ))
        [[ "$utime" -lt "$unchtime" ]] && rm ${PBS_SERVER_HOME}/mom_priv/mom.lock
    fi

    ebegin "Starting Torque pbs_mom"
    local extra_args=""
    if [ -n "${PBS_MOM_LOG}" ]; then
        extra_args="-L ${PBS_MOM_LOG}"
    fi
    start-stop-daemon  --start -p ${PBS_SERVER_HOME}/mom_priv/mom.lock \
        --exec /usr/sbin/pbs_mom -- -d ${PBS_SERVER_HOME} ${extra_args}
    eend ${?}		
}

stop() {
    ebegin "Stopping Torque pbs_mom"
    /usr/sbin/momctl -s  || start-stop-daemon --stop -p ${PBS_SERVER_HOME}/mom_priv/mom.lock
    eend ${?}
}

restart() {
    svc_stop
    sleep 3
    svc_start
}
# vim:ts=4
