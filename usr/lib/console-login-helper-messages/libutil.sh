#!/bin/bash

# Collection of util functions and common definitions for
# console-login-helper-messages scripts.

PKG_NAME="console-login-helper-messages"

# On distributions where Network Manager is not used, udev rules could be used
# to detect new interfaces being added/removed.
# Udev rules are disabled by default and do not support complex networking
# devices or network interfaces with custom names.
USE_UDEV_FOR_NETWORK_SNIPPETS="false"

# On distributions that have util-linux >= 2.36, public runtime directories
# (e.g. `/run/motd.d`) can be used. Use this hardcoded variable so we can
# keep the test files the same across the two branches of c-l-h-m.
USE_PUBLIC_RUN_DIR="true"

tempfile_template="${PKG_NAME}.XXXXXXXXXX.tmp"
# Use same filesystem, under /run, as where snippets are generated, so
# that rename operations through `mv` are atomic.
tempfile_dir="/run/${PKG_NAME}"
# Define the restorecon command to run to apply the default SELinux
# to the destination file e.g. for sshd which requires that written
# files in `/run/motd.d` maintain the type `pam_var_run_t`. If no
# restorecon command exists on the system we'll run `true` instead
# as a noop.
restorecon=$(command -v restorecon || echo "true")

# Write stdin to a tempfile, and rename the tempfile to the path given
# as an argument. When called from multiple processes on the same
# generated file path, this avoids interleaving writes to the generated
# file by using `mv` to overwrite the file.
write_via_tempfile() {
    mkdir -p "${tempfile_dir}"
    local generated_file="$1"
    local staged_file="$(mktemp --tmpdir="${tempfile_dir}" "${tempfile_template}")"
    cat > "${staged_file}"
    chmod a+r "${staged_file}"
    mv "${staged_file}" "${generated_file}"
    ${restorecon} "${generated_file}"
}

