#!/sbin/runscript
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/files/Attic/pvfs2-server-init.d-2.7.0,v 1.2 2011/07/15 13:57:08 xarthisius dead $

PVFS2_NAME=${SVCNAME##*.}
if [[ -n "${PVFS2_NAME}" && "${SVCNAME}" != "pvfs2-server" ]]; then
    PVFS2_PID_DEFAULT="/var/run/pvfs2.${PVFS2_NAME}.pid"
    PVFS2_CONF_DEFAULT="/etc/pvfs2/${PVFS2_NAME}.fs.conf"
else
    PVFS2_PID_DEFAULT="/var/run/pvfs2.pid"
    PVFS2_CONF_DEFAULT="/etc/pvfs2/fs.conf"
fi
PVFS2_PID=${PVFS2_PID:-${PVFS2_PID_DEFAULT}}
PVFS2_CONF=${PVFS2_CONF:-${PVFS2_CONF_DEFAULT}}
PVFS2_SERVER=${PVFS2_SERVER:-"/usr/sbin/pvfs2-server"}
PVFS2_AUTO_MKFS=${PVFS2_AUTO_MKFS:-"no"}
PVFS2_STARTUP_WAIT=${PVFS2_STARTUP_WAIT:-1000}

depend() {
    after localmount netmount nfsmount dns
    use net
}

checkconfig() {
    # server will not create pyid directory itself
    local piddir=$(dirname "${PVFS2_PID}")
    checkpath -d "${piddir}"

    # check for config file
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

    # check for corrent data and metadata storage specifications
    data=$(grep DataStorageSpace "${PVFS2_CONF}" | cut -d' ' -f 2)
    meta=$(grep MetadataStorageSpace "${PVFS2_CONF}" | cut -d' ' -f 2)
    if [[ -z "${data}" || -z "${meta}" ]]; then
        eerror "Config file ${PVFS2_CONF} is not valid:"
        eerror "DataStorageSpace and MetadataStorageSpace must be specified."
        return 1
    fi

}

start() {
    local rc
    checkconfig || return 1

    ebegin "Starting PVFS2 server"

    # Check if filesystem already exists.
    local stream=""
    [[ -d "${data}" ]] &&
        stream=$(find -O3 "${data}" -mindepth 2 -maxdepth 2 -type d -name bstreams)
    # both data and metadata are ok
    if [[ -f "${meta}/collections.db" && -n "${stream}" ]]; then
        rc=0;
    # both data and metadata are missing
    elif [[ ! -f "${meta}/collections.db" && -z "${stream}" ]]; then
        if yesno ${PVFS2_AUTO_MKFS}; then
            ewarn "Initializing the file system storage with --mkfs"
            "${PVFS2_SERVER}" ${PVFS2_OPTIONS} --mkfs "${PVFS2_CONF}"
        rc=$?
        else
            eerror "PVFS2 filesystem was not created."
            eerror "Set PVFS2_AUTO_MKFS=\"yes\" in the conf.d file to create it automatically,"
            eerror "or create it manually using ${PVFS2_SERVER} --mkfs ${PVFS2_CONF}"
            return 1
        fi
    # data xor metadata exists
    else
        eerror "Both DataStorageSpace and MetadataStorageSpace directories"
        eerror "must be generated. Only one is on your system."
        eerror "Something is terribly wrong with your PVFS2, check it manually."
        return 1
    fi

    if [[ ${rc} -eq 0 ]]; then
        start-stop-daemon --start \
            --exec ${PVFS2_SERVER} --wait ${PVFS2_STARTUP_WAIT} \
            -- -p "${PVFS2_PID}" ${PVFS2_OPTIONS} "${PVFS2_CONF}"
        rc=$?
    fi

    unset data meta

    [[ ${rc} -ne 0 ]] && return 1
    eend ${rc}
}

stop() {
    local rc i
    ebegin "Stopping PVFS2 server"
    start-stop-daemon --stop  --quiet --pidfile "${PVFS2_PID}"
    rc=$?

    # pvfs2-server doesn't clean shm on stop
    for i in $(ipcs -m | gawk '($6 == "0" && $3 == "root") {print $2}'); do
        ipcrm -m ${i};
    done

    eend ${rc}
}

restart() {
    svc_stop
    sleep 2
    svc_start
}
