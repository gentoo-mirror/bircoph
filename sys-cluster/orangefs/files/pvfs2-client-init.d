#!/sbin/runscript
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-client-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

PVFS2_CLIENT_PID=${PVFS2_CLIENT_PID:-"/var/run/pvfs2-client.pid"}
PVFS2_CLIENT=${PVFS2_CLIENT:-"/usr/sbin/pvfs2-client"}
PVFS2_CLIENT_CORE=${PVFS2_CLIENT_CORE:-"/usr/sbin/pvfs2-client-core"}
PVFS2_CLIENT_LOG=${PVFS2_CLIENT_LOG:-"/var/log/pvfs2/client.log"}
PVFS2_CLIENT_FSTAB=${PVFS2_CLIENT_FSTAB:-"/etc/fstab"}
PVFS2_CLIENT_UNLOAD_MODULE=${PVFS2_CLIENT_UNLOAD_MODULE:-"yes"}

depend() {
    after pvfs2-server
    before pbs_mom
    need net localmount
}

start() {
    local piddir=$(dirname "${PVFS2_CLIENT_PID}")
    [[ -d "${piddir}" ]] || ( mkdir -p "${piddir}" || return 1 )

    if ! grep -qs pvfs2 /proc/filesystems; then
        ebegin "Loading pvfs2 kernel module"
        modprobe pvfs2
        eend $? "failed"
        [[ $? -ne 0 ]] && return 1
    fi

    ebegin "Starting pvfs2-client"
    # Don't fork the client so we can get the pid with s-s-d.
    start-stop-daemon --start --quiet --background \
        --make-pidfile --pidfile "${PVFS2_CLIENT_PID}" \
        --exec "${PVFS2_CLIENT}" \
        -- -f -p "${PVFS2_CLIENT_CORE}" -L "${PVFS2_CLIENT_LOG}" \
        ${PVFS2_CLIENT_ARGS}
    eend $?

    local mp rc=0
    ebegin "Mounting pvfs2 filesystems"
    if ! [[ -r "${PVFS2_CLIENT_FSTAB}" ]]; then
        error "${PVFS2_CLIENT_FSTAB} is not readable."
        rc=1
    else
        # grep all pvfs2 entries save for noauto
        for mp in $(gawk '($3 == "pvfs2" && !index($4, "noauto")) { print $2 }' /etc/fstab); do
            mount "${mp}" || { eerror "Failed to mount ${mp}"; rc=1; }
        done
    fi
    eend ${rc}
    # pvfs2 client is useful even with failed mounts
    return 0
}

stop() {
    local mp rc=0
    ebegin "Unmounting pvfs2 filesystems"
    if ! [[ -r "/etc/mtab" ]]; then
        error "/etc/mtab is not readable."
        rc=1
    else
        # grep all pvfs2 entries save for noauto
        for mp in $(gawk '($3 == "pvfs2") { print $2 }' /etc/mtab); do
            umount "${mp}" || { eerror "Failed to umount ${mp}"; rc=1; }
        done
    fi
    eend ${rc}
    [[ ${rc} -ne 0 ]] && return 1

    ebegin "Stopping pvfs2-client"
    start-stop-daemon --stop --pidfile "${PVFS2_CLIENT_PID}"
    eend

    if [[ $? == 0 ]] && yesno ${PVFS2_CLIENT_UNLOAD_MODULE}; then
        ebegin "Unloading pvfs2 kernel module"
        rmmod pvfs2
        eend $? "failed"
    fi
}
