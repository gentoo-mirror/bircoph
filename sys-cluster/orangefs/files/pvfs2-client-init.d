#!/sbin/runscript
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-client-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

PVFS2_CLIENT_PID=${PVFS2_CLIENT_PID:-"/var/run/pvfs2-client.pid"}
PVFS2_CLIENT=${PVFS2_CLIENT:-"/usr/sbin/pvfs2-client"}
PVFS2_CLIENT_CORE=${PVFS2_CLIENT_CORE:-"/usr/sbin/pvfs2-client-core"}
PVFS2_CLIENT_PING=${PVFS2_CLIENT_PING:-"/usr/bin/pvfs2-ping"}
PVFS2_CLIENT_LOG=${PVFS2_CLIENT_LOG:-"/var/log/pvfs2/client.log"}
PVFS2_CLIENT_FSTAB=${PVFS2_CLIENT_FSTAB:-"/etc/fstab"}
PVFS2_CLIENT_UNLOAD_MODULE=${PVFS2_CLIENT_UNLOAD_MODULE:-"yes"}
PVFS2_CLIENT_CHECK_SERVERS=${PVFS2_CLIENT_CHECK_SERVERS:-"yes"}
PVFS2_CLIENT_CHECK_MAX_FAILURE=${PVFS2_CLIENT_CHECK_MAX_FAILURE:-5}
PVFS2_CLIENT_FORCE_UMOUNT=${PVFS2_CLIENT_FORCE_UMOUNT:-"no"}

depend() {
    after pvfs2-server
    before pbs_mom
    need net localmount
}

start() {
    local piddir=$(dirname "${PVFS2_CLIENT_PID}")
    checkpath -d "${piddir}"

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
            if yesno "${PVFS2_CLIENT_CHECK_SERVERS}"; then
                for ((i=0; i<${PVFS2_CLIENT_CHECK_MAX_FAILURE}; i++)); do
                    "${PVFS2_CLIENT_PING}" -m "${mp}" >/dev/null 2>&1 && break
                    ewarn "servers for ${mp} are not ready, retrying"
                done
            fi
            mount "${mp}" || { eerror "Failed to mount ${mp}"; rc=1; }
        done
    fi
    eend ${rc}
    # pvfs2 client is useful even with failed mounts
    return 0
}

stop() {
    local mp rc=0 lrc=0 list
    ebegin "Unmounting pvfs2 filesystems"
    if ! [[ -r "/etc/mtab" ]]; then
        error "/etc/mtab is not readable."
        rc=1
    else
        # grep all pvfs2 entries save for noauto
        for mp in $(gawk '($3 == "pvfs2") { print $2 }' /etc/mtab); do
            umount "${mp}"
            lrc=$?
            if [[ ${lrc} -ne 0 ]]; then
                if yesno "${PVFS2_CLIENT_FORCE_UMOUNT}"; then
                    ewarn "Normal ${mp} unmount failed. Forcing..."
                    list=$(lsof -nt /mnt/cluster)
                    umount -l "${mp}"
                    # soft kill
                    if [[ -n ${list} ]]; then
                        kill ${list}
                        sleep 1
                        # hard kill hanged ones
                        ps ${list} >/dev/null && kill -9 ${list}
                        sleep 0.5
                        # if some processes are still hang
                        if ps ${list} >/dev/null; then
                            eerror "${mp} was not completely unmounted!"
                            eerror "leftover processes: ${list}"
                            rc=1
                        else
                            lrc=0
                        fi
                    fi
                    [[ ${lrc} -eq 0 ]] && ewarn "${mp} was forcefully unmounted"
                else
                    eerror "Failed to umount ${mp}"
                    rc=1
                fi
            fi
        done
    fi
    eend ${rc}
    [[ ${rc} -ne 0 ]] && return 1

    ebegin "Stopping pvfs2-client"
    start-stop-daemon --stop --pidfile "${PVFS2_CLIENT_PID}"
    eend

    if [[ $? == 0 ]] && yesno "${PVFS2_CLIENT_UNLOAD_MODULE}"; then
        einfo "Waiting before module unload..."
        # wait for a while is recommended by pvfs2 guide
        sleep 1
        ebegin "Unloading pvfs2 kernel module"
        rmmod pvfs2
        eend $? "failed"
    fi
}
