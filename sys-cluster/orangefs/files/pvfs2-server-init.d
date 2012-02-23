#!/sbin/runscript
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-server-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

PVFS2_NAME=${SVCNAME##*.}
if [[ -n "${PVFS2_NAME}" && "${SVCNAME}" != "pvfs2-server" ]]; then
    PVFS2_PID="/var/run/pvfs2.${PVFS2_NAME}.pid"
    PVFS2_CONF_DEFAULT="/etc/pvfs2/${PVFS2_NAME}.fs.conf"
else
    PVFS2_PID="/var/run/pvfs2.pid"
    PVFS2_CONF_DEFAULT="/etc/pvfs2/fs.conf"
fi
PVFS2_CONF=${PVFS2_CONF:-${PVFS2_CONF_DEFAULT}}
PVFS2_SERVER=${PVFS2_SERVER:-/usr/sbin/pvfs2-server}

depend() {
    after localmount netmount nfsmount dns
    use net
}

checkconfig() {
    # server will not create directories itself
    local piddir=$(dirname "${PVFS2_PID}")
    [[ -d "${piddir}" ]] || ( mkdir -p "${piddir}" || return 1 )

    if ! [[ -r "${PVFS2_CONF}" ]]; then
        eerror "Could not read ${PVFS2_CONF}"
        eerror "To create one you may use:"
    if [[ -z "${PVFS2_NAME}" || "${SVCNAME}" == "pvfs2-server" ]]; then
        eerror "  emerge --config orangefs"
        eerror "for single server setup, or"
    fi
        eerror "  mkdir $(dirname ${PVFS2_CONF})"
        eerror "  pvfs2-genconfig ${PVFS2_CONF}"
    if [[ -z "${PVFS2_NAME}" || "${SVCNAME}" == "pvfs2-server" ]]; then
        eerror "for general profile."
    fi
        return 1
    fi
    
    # server will not start if is not able to create logfile
    local logfile=$(gawk '($1 == "LogFile") { print $2 }' "${PVFS2_CONF}")
    if [[ -z "${logfile}" ]]; then
        eerror "Config file is invalid: it must contain LogFile parameter"
        return 1
    fi
    local logdir=$(dirname "${logfile}")
    [[ -d "${logdir}" ]] || ( mkdir -p "${logdir}" || return 1 )
}

start() {
    local rc
    checkconfig || return 1
    
    ebegin "Starting PVFS2 server"
    
    # Optionally force pvfs2-server to generate the pvfs2 filesystem.
    if [[ ${PVFS2_AUTO_MKFS} -ne 0 && \
        ! -f $(grep StorageSpace ${PVFS2_CONF} | cut -d' ' -f 2)/collections.db ]]; then
        ewarn "Initializing the file system storage with --mkfs"
        "${PVFS2_SERVER}" --mkfs "${PVFS2_CONF}"
        rc=$?
    fi

    einfo "starting ${PVFS2_SERVER} -p ${PVFS2_PID} ${PVFS2_OPTIONS} ${PVFS2_CONF}"
    if [[ ${rc} -eq 0 ]]; then 
        start-stop-daemon -b --start --quiet \
            --pidfile "${PVFS2_PID}" \
            --exec "${PVFS2_SERVER}" \
            -- -p "${PVFS2_PID}" ${PVFS2_OPTIONS} "${PVFS2_CONF}"
        rc=$?
    fi
    eend ${rc}
}

stop() {
    ebegin "Stopping PVFS2 server"
    start-stop-daemon --stop  --quiet --pidfile "${PVFS2_PID}"
    eend
}

restart() {
    svc_stop
    sleep 2
    svc_start
}
