#!/bin/bash
# The STDOUT of this executable will be printed to GitLab Runner logs at a DEBUG level. The STDERR will be printed to the logs at a WARN level. 
source /var/lib/builder/gitlab_executor_custom/shared.bash
log_info "gitlab ci step cleanup: args($@)"

sudo machinectl stop "$MACHINEID"

sudo umount "$MOUNTPOINT"

# Step unnecessary if using --ephemeral
sudo rm -rf "$OVERLAYFS" "$MOUNTPOINT" "$WORKDIR"

# But ephemeral does not work because run is called multiple times and 
# container does not persist between these calls
