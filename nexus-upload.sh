#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The LMinux Foundation <matthew.watkins@linuxfoundation.org>

# Uncomment to enable debugging
# set -vx

CURL_CONFIG=".netrc"
# Count file upload successes/failures
SUCCESSES="0"; FAILURES="0"

# Shared functions

show_help() {
    # Command usage help
    cat << EOF
Usage: ${0##*/} [-h] -r repository -d directory [-e file extension]
    -h  display this help and exit
    -r  remote repository name (mandatory)
    -d  local directory of files to upload (mandatory)
    -e  match file extension (optional)
EOF
}

error_help() {
    show_help >&2
    exit 1
}

status_report() {
    if [ "$FAILURES" -eq 0 ]; then
        ERRORS="false"; EXIT_STATUS="0"
    else
        ERRORS="true"; EXIT_STATUS="1"
    fi

    # Print a helpful status summary
    echo "Errors: $ERRORS   Successes: $SUCCESSES   Failures: $FAILURES"
    export ERRORS SUCCESSES FAILURES
    exit "$EXIT_STATUS"
}

curl_upload() {
    FILE="$1"
    echo "Sending: ${FILE}"
    if ("$CURL" --no-progress-meter --fail --netrc-file "$CURL_CONFIG" \
        --upload-file "$FILE" "$NEXUS_URL"); then #> /dev/null 2>&1
        SUCCESSES=$((SUCCESSES+1))
    else
        FAILURES=$((FAILURES+1))
    fi
}

process_files() {
    for FILE in "${UPLOAD_FILES_ARRAY[@]}"; do
        curl_upload "$FILE"
    done
}

# Check environment and set variables

CURL=$(which curl)
if [ ! -x "$CURL" ];then
    echo "cURL was not found in your PATH"; exit 1
fi

while getopts hr:d:e: opt; do
    case $opt in
        r)  NEXUS_REPOSITORY="$OPTARG"
            ;;
        d)  UPLOAD_DIRECTORY="$OPTARG"
            if [ ! -d "$UPLOAD_DIRECTORY" ]; then
                echo "Error: specified upload directory not found"; exit 1
            fi
            ;;
        e)  FILE_EXTENSION="$OPTARG" # Not mandatory
            ;;

        # Not implemented; this parameter may be superfluous
        # REPOSITORY_FORMAT

        h|?)
            show_help
            exit 0
            ;;
        *)
            error_help
        esac
done
shift "$((OPTIND -1))" # Discard the options

# Check for required parameters and setup
if [ -z ${NEXUS_REPOSITORY+x} ]; then
    echo "Supplying the repository is mandatory"
    ERRORS="true"
fi
if [ -z ${UPLOAD_DIRECTORY+x} ]; then
    echo "Supplying the upload directory is mandatory"
    ERRORS="true"
fi
if [ ! -f "$CURL_CONFIG" ];then
    echo "cURL configuration file was not found ($CURL_CONFIG)"
    ERRORS="true"
else
    # The server name is extracted from the configuration file
    NEXUS_SERVER=$(grep machine "$CURL_CONFIG" | awk '{print $2}')
fi
if [ "$ERRORS" = "true" ];then
    FAILURES=$((FAILURES+1))
    status_report
fi

# Gather files to upload into an array (does not traverse directories recursively)
mapfile -t UPLOAD_FILES_ARRAY < <(find "$UPLOAD_DIRECTORY" -name "*$FILE_EXTENSION" -maxdepth 1 -type f -print)

if [ "${#UPLOAD_FILES_ARRAY[@]}" -ne 0 ]; then
    echo "Number of files to upload: ${#UPLOAD_FILES_ARRAY[@]}"
else
    echo "No files found matching pattern: $UPLOAD_DIRECTORY/*$FILE_EXTENSION"
    FAILURES=$((FAILURES+1))
    status_report
fi

# Combine separate parameters into NEXUS_URL
if [[ -n ${NEXUS_SERVER+x} ]] && [[ -n ${NEXUS_REPOSITORY+x} ]]; then
    NEXUS_URL="https://$NEXUS_SERVER/repository/$NEXUS_REPOSITORY/"
else
    echo "A required parameter was not supplied"
    echo "NEXUS_SERVER: $NEXUS_SERVER"
    echo "NEXUS_REPOSITORY: $NEXUS_REPOSITORY"; exit 1
fi

# Example .netrc configuration file format:
# machine $NEXUS_SERVER login $NEXUS_USERNAME password $NEXUS_PASSWORD

echo "Attempting uploads to: $NEXUS_URL"
process_files
status_report
