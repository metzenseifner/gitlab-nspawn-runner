#!/bin/bash

# The STDOUT and STDERR returned from this executable will print to the job log. 

# Setup Global Environment Variables
source /var/lib/builder/gitlab_executor_custom/shared.bash
#set -eo pipefail

# Trap errors as a CI SYSTEM FAILURE (2)
#trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

log_info "Running gitlab ci step prepare: base($ROOTFS) overlay($OVERLAYFS) machine_id($MACHINEID) args($@)"

# mount -t overlay overlay -o lowerdir=/mnt/local/nothighavail/nothighavail/bootstrapped_base_systems/centos8,upperdir=/mnt/local/nothighavail/nothighavail/machines/manualtest,workdir=/mnt/local/nothighavail/nothighavail/work /mnt/local/nothighavail/nothighavail/merged

# Must be cleaned up
mkdir "$OVERLAYFS" "$MOUNTPOINT" "$WORKDIR"
sudo mount -v -t overlay overlay -o lowerdir="$ROOTFS",upperdir="$OVERLAYFS",workdir="$WORKDIR" "$MOUNTPOINT"

# Use systemd-run to imitate systemd-nspawn@.service instead of creating
# a unit per gitlabrunner job.
# use --notify-ready=yes to solve race condition of running command before fully booted
#  -p 'RestartForceExitStatus=134' \
#  -p 'SuccessExitStatus=133' \
#    --overlay "$ROOTFS":"$OVERLAYFS":/root \   # ticket https://github.com/systemd/systemd/issues/3847
sudo systemd-run \
  -p 'KillMode=mixed' \
  -p 'Type=notify' \
  -p 'Slice=machine.slice' \
  -p 'Delegate=yes' \
  -p 'TasksMax=16384' \
  -p 'WatchdogSec=3min' \
  systemd-nspawn \
    --quiet \
    -D "$MOUNTPOINT" \
    --private-users=0 \
    --private-users-chown \
    --machine="$MACHINEID" \
    --boot \
    --notify-ready=yes \
    --bind=${NETSHAREFS}:${NETSHAREFS} \
    --bind=${PERSISTENTFS}:${PERSISTENTFS} \
    --bind="$SSH_KEY:/mnt/local/ssh_private.key" \
    --bind="$ANSIBLE_VAULT_AV_PASS_FILE:/mnt/local/av_vault.pass"
    #--bind=/mnt/local/nothighavail/nothighavail/build:/var/lib/builder/build \
    #--bind=/mnt/local/nothighavail/nothighavail/cache:/var/lib/builder/cache
# beware: if the bind mounts do not exist or permissions are off, weird errors follow like mkdir: cannot create directory
# Note that --bind is mostly incompatible with --private-users because the resulting mount points will be owned by NOBODY users because the host files continue to be owned by the respective host owners, which with --private-users would no longer exist. --bind-ro= is recommended in this case. A UID:GID is required on both the host and the user for --bind to work properly.
# using -D "$OVERLAYFS" --template="$ROOTFS" leads to ==> Directory tree /var/lib/builder/machines/run-1 is currently busy.
# 2021-12-02 removed --chdir=/tmp
