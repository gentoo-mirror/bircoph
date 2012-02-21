#!/sbin/runscript
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-server-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

depend() {
    after localmount netmount nfsmount dns
    use net
}


checkconfig() {
    local piddir=$(dirname "${PVFS2_PIDFILE}")
    if [ ! -d "${piddir}" ]; then
        mkdir -p "${piddir}" || return 1
    fi

    if ! [ -r "${PVFS2_FS_CONF}" ]; then
        eerror "Could not read ${PVFS2_FS_CONF}"
        return 1
    fi
}

start() {
    local rc
    checkconfig || return 1
    
    ebegin "Starting PVFS2 server"
    
    # Optionally force pvfs2-server to generate the pvfs2 filesystem.
    if [[ ${PVFS2_AUTO_MKFS} -ne 0 && \
        ! -f $(grep StorageSpace ${PVFS2_FS_CONF} | cut -d' ' -f 2)/collections.db ]]; then
        ewarn "Initializing the file system storage with --mkfs"
        "${PVFS2_SERVER}"  --mkfs "${PVFS2_FS_CONF}"
        rc=$?
    fi

    if [[ ${rc} -eq 0 ]]; then 
        start-stop-daemon -b --start  --quiet \
            --pidfile "${PVFS2_PIDFILE}" \
            --exec "${PVFS2_SERVER}" \
            -- -p "${PVFS2_PIDFILE}" ${PVFS2_OPTIONS} "${PVFS2_FS_CONF}"
        rc=$?
    fi
    eend ${rc}
}

stop() {
    checkconfig || return 1
    ebegin "Stopping PVFS2 server"
    start-stop-daemon --stop  --quiet --pidfile "${PVFS2_PIDFILE}"
    eend
}

restart() {
    svc_stop
    sleep 2
    svc_start
}
