# Extra arguments to supply to the pvfs2-client daemon
#PVFS2_CLIENT_LOG="/var/log/pvfs2/client.log"

# Extra arguments to supply to the pvfs2-client daemon
#PVFS2_CLIENT_ARGS=""

# Where to fetch pvfs2 mount entries from.
# Entries with noauto option are ignored.
#PVFS2_CLIENT_FSTAB="/etc/fstab"

# Allows to unload pvfs2 kernel module on stop
#PVFS2_CLIENT_UNLOAD_MODULE="yes"

# Check if all servers are ready.
#PVFS2_CLIENT_CHECK_SERVERS="yes"

# If servers check above is enabled, this option determines how
# many times to run pvfs2-ping check before giving up on a mount
# point. Single pvfs2-ping run takes about 10 seconds if server is
# unavailable.
#PVFS2_CLIENT_CHECK_MAX_FAILURE=5

# If file system is in use, forces its umount in the following steps:
# 1) Lazily umount pvfs2;
# 2) Send SIGTERM to all processes (using pvfs2 in question).
# 3) Wait for 1 second.
# 4) Send SIGKILL to all processes (using pvfs2 in question).
# Then continue stop procedures as usual.
#PVFS2_CLIENT_FORCE_UMOUNT="no"
