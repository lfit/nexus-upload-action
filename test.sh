#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation <matthew.watkins@linuxfoundation.org>

# shellcheck disable=all

### Nexus Test Upload Script ###

DATETIME=$(date '+%Y%m%d-%H%M')
UPLOAD_DIRECTORY="files"
FILENAME_SUFFIX=".txt"
NEXUS_REPOSITORY="testing"

# Create test file to upload
if [ ! -d "$UPLOAD_DIRECTORY" ]; then
    mkdir "$UPLOAD_DIRECTORY"
fi
echo "Test file $DATETIME" > "$UPLOAD_DIRECTORY/upload-$DATETIME.txt"

# Invoke the script to upload the test file
./nexus-upload.sh -r "$NEXUS_REPOSITORY" -d "$UPLOAD_DIRECTORY" -e "$FILENAME_SUFFIX"

# Remove the test file from the local system afterwards
rm "$UPLOAD_DIRECTORY/upload-$DATETIME.txt" > /dev/null 2>&1
