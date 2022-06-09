#!/bin/bash
# The STDOUT and STDERR returned from this executable will print to the job log. 
# executed by run_exec

source "/var/lib/builder/gitlab_executor_custom/shared.bash"
log_info "gitlab ci step run: args($@)"

#set -o pipefail

# Catch signals. EXIT_CODE as a CI SYSTEM FAILURE (2)
#trap "echo 'Trapped SIGKILL on line $LINENO (caller: $caller); Possible timeout reached.'; exit $SYSTEM_FAILURE_EXIT_CODE" SIGKILL
#trap "echo 'Trapped ERR on line $LINENO (caller: $caller)'; exit $SYSTEM_FAILURE_EXIT_CODE" ERR

# Create global directories in namespace $MACHINEID
sudo systemd-run --quiet --pipe --wait --machine="$MACHINEID" -E PERSISTENT_DIR="$PERSISTENT_NSPAWN_DIR" /usr/bin/mkdir -p "$PERSISTENT_NSPAWN_DIR"
# Only create netshare dir only if needed: callers responsibility. Safely done because NETSHARE_DIR is set by build system.

# Pass strings from .gitlab-ci.yml/script into stdin of bash running in namespace $MACHINEID
sudo systemd-run --quiet --pipe --wait --machine="$MACHINEID" -E PERSISTENT_DIR="$PERSISTENT_NSPAWN_DIR" -E NETSHARE_DIR="$NETSHARE_NSPAWN_DIR" -E BASH_ENV=/etc/bashrc /bin/bash -- 0< ${1}
