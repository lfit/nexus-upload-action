#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The LMinux Foundation <matthew.watkins@linuxfoundation.org>

# shellcheck disable=all

### Nexus Test Upload Script ###

NEXUS_USERNAME="admin"
NEXUS_SERVER="nexus3.o-ran-sc.org"
NEXUS_REPOSITORY="datasets"
FILENAME_SUFFIX=".txt"
UPLOAD_DIRECTORY="files"

# Set this to the current password from 1Password
# e.g. ORAN Nexus3 (admin user)
# then uncomment and run the script
# NEXUS_PASSWORD="********"

# Note: Uploads will fail if the file already exists in the remote repository
# shellcheck disable=SC1094
source nexus-upload.sh
