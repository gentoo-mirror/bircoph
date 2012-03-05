#!/sbin/runscript
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-client-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

PVFS2_CLIENT_PID=${PVFS2_CLIENT_PID:-"/var/run/pvfs2-client.pid"}
PVFS2_CLIENT=${PVFS2_CLIENT:-"/usr/sbin/pvfs2-client"}
PVFS2_CLIENT_CORE=${PVFS2_CLIENT_CORE:-"/usr/sbin/pvfs2-client-core"}
PVFS2_CLIENT_LOG=${PVFS2_CLIENT_LOG:-"/var/log/pvfs2/client.log"}

depend() {
    after pvfs2-server fuse
    before pbs_mom
    need net localmount
}

checkconfig() {
    local piddir=$(dirname ${PVFS2_CLIENT_PID})
    [[ -d "${piddir}" ]] || ( mkdir -p "${piddir}" || return 1 )
}

start() {
    local rc=0
    local server_mp server mp
    checkconfig || return 1
    ebegin "Starting pvfs2-client"

    if ! grep -qs pvfs2 /proc/filesystems; then
        eerror "Kernel does not support pvfs2 filesystems"
        return 1
    fi

    # Don't fork the client so we can get the pid with s-s-d.
    if ! start-stop-daemon --start -m -b --quiet \
        --pidfile ${PVFS2_CLIENT_PIDFILE} \
        --exec "${PVFS2_CLIENT}" \
        -- -f -p ${PVFS2_CLIENT_CORE} ${PVFS2_CLIENT_ARGS}; then
        rc=1
    elif [ -n "${PVFS2_MOUNTS}" ]; then
        for server_mp in ${PVFS2_MOUNTS}; do
            mount -t pvfs2 \
                tcp://$(echo ${server_mp} | cut -d',' -f1)/pvfs2-fs \
                $(echo ${server_mp} | cut -d',' -f2)
            rc=$?
            [[ ${rc} -ne 0 ]] && break
        done
        [[ ${rc} -ne 0 ]] && start-stop-daemon --stop -p ${PVFS2_CLIENT_PIDFILE} 
    fi

    eend ${rc}
}

stop() {
    local rc=0
    local server_mp
    checkconfig || return 1
    ebegin "Stopping pvfs2-client"

    if [ -n "${PVFS2_MOUNTS}" ]; then
        for server_mp in ${PVFS2_MOUNTS}; do
            umount -f $(echo ${server_mp} | cut -d',' -f2)
            rc=$?
            [[ ${rc} -ne 0 ]] && break
        done
    fi

    if [[ ${rc} -eq 0 ]]; then
        start-stop-daemon --stop -p ${PVFS2_CLIENT_PIDFILE} 
        rc=$?
    fi

    eend ${rc}
}

