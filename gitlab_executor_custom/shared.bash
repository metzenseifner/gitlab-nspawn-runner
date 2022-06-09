#!/bin/bash

function log_info() {
	local msg=$1
	logger "$msg"
	printf "${msg}\n"
}

log_info "Executing under UID $(id -u)"

# see https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
# see special note about predefined variables https://docs.gitlab.com/runner/executors/custom.html
# predefined variables are prefixed with CUSTOM_ENV_ to prevent conflicts with system environment variables.

# systemd-nspawn Essentials
# using explicit MACHINEID allows multiple commands for a machines lifetime
# Note that failed jobs leave lingering files using CUSTOM_ENV_CI_JOB_ID
# namespace for debugging. This also means rerunning failed jobs
# could require manually cleaning up the namespace run-$CUSTOM_ENV_CI_JOB_ID
# because gitlab seems a bit unreliable generating ids per run.
# umount -l  machines/run-107099
# lazy approach:
# rm -rf workdirs/* overlays/* machines/*
MACHINEID="run-$CUSTOM_ENV_CI_JOB_ID"
ROOTFS="/var/lib/machines/centosstream8-all-in-one-builder"
OVERLAYFS="/mnt/local/nothighavail/nothighavail/overlays/$MACHINEID"
WORKDIR="/mnt/local/nothighavail/nothighavail/workdirs/$MACHINEID"
MOUNTPOINT="/mnt/local/nothighavail/nothighavail/machines/$MACHINEID"

# File Systems
PERSISTENTFS="/mnt/local/nothighavail/nothighavail/persistent"
PERSISTENT_PIPELINE_DISTINGUISHER="$CUSTOM_ENV_CI_PROJECT_PATH/pipe_$CUSTOM_ENV_CI_PIPELINE_ID"
NETSHAREFS="/mnt/remote/smb/netshare_build_hidden"
NETSHARE_BRANCH_DISTINGUISHER="projects/$CUSTOM_ENV_CI_PROJECT_NAME/branches/$(printf $CUSTOM_ENV_CI_COMMIT_BRANCH | sed 's|/|-|g')"
SSH_KEY="/var/lib/builder/.ssh/id_ed25519"
ANSIBLE_VAULT_AV_PASS_FILE="/var/lib/builder/av_vault.password"

# Namespaced Directories
PERSISTENT_NSPAWN_DIR="$PERSISTENTFS/$PERSISTENT_PIPELINE_DISTINGUISHER"
NETSHARE_NSPAWN_DIR="$NETSHAREFS/$NETSHARE_BRANCH_DISTINGUISHER"
