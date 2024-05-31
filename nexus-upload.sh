#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The LMinux Foundation <matthew.watkins@linuxfoundation.org>

# Uncomment to enable debugging
# set -vx

# Initialise variables
UPLOAD_DIRECTORY="."
FILE_EXTENSION=""
# Count file upload successes/failures
SUCCESSES="0"; FAILURES="0"

# Shared functions

show_help() {
    # Command usage help
    cat << EOF
Usage: ${0##*/} [-h] [-u user] [-p password] [-s url] [-e file extension] [-d folder]
    -h  display this help and exit
    -u  username (NEXUS_USERNAME)
    -p  password (NEXUS_PASSWORD)
    -s  Nexus server URL (NEXUS_URL)
        e.g. https://nexus3.o-ran-sc.org/repository/datasets/
    -d  local directory (UPLOAD_DIRECTORY)
    -e  match file extension (FILE_EXTENSION)
        e.g. csv, txt
Note:
    You can also pass NEXUS_SERVER and NEXUS_REPOSITORY as variables
    In this case, NEXUS_URL will be synthesied as a composite string
    e.g. https://$NEXUS_SERVER/repository/$NEXUS_REPOSITORY
EOF
}

error_help() {
    show_help >&2
    exit 1
}

transfer_report() {
    echo "Successes: $SUCCESSES   Failures: $FAILURES"
    # Export allows these values to be used later
    export SUCCESSES FAILURES
    if [ "$FAILURES" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

curl_upload() {
    FILE="$1"
    echo "Sending: ${FILE}"
    # echo "Running: $CURL --fail [CREDENTIALS] --upload-file $FILE $NEXUS_URL"
    if ("$CURL" --fail -u "$CREDENTIALS" --upload-file "$FILE" "$NEXUS_URL"); then #> /dev/null 2>&1
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

# Validate/check arguments and variables

CURL=$(which curl)
if [ ! -x "$CURL" ];then
    echo "CURL was not found in your PATH"; exit 1
fi


while getopts hu:p:s:d:e: opt; do
    case $opt in
        u)  NEXUS_USERNAME="$OPTARG"
            ;;
        p)  NEXUS_PASSWORD="$OPTARG"
            ;;
        s)  NEXUS_URL="$OPTARG"
            ;;
        e)  FILE_EXTENSION="$OPTARG"
            ;;
        d)  UPLOAD_DIRECTORY="$OPTARG"
            if [ ! -d "$UPLOAD_DIRECTORY" ]; then
                echo "Error: specified directory invalid"; exit 1
            fi
            ;;
        # Not implemented yet, this parameter may be superfluous
        # REPOSITORY_FORMAT
        h|?)
            show_help
            exit 0
            ;;
        *)
            error_help
        esac
done
shift "$((OPTIND -1))"   # Discard the options

# Gather files to upload into an array
# (note: does not traverse directories recursively)
mapfile -t UPLOAD_FILES_ARRAY < <(find "$UPLOAD_DIRECTORY" -name "*$FILE_EXTENSION" -maxdepth 1 -type f -print)

if [ "${#UPLOAD_FILES_ARRAY[@]}" -ne 0 ]; then
    echo "Files found to upload: ${#UPLOAD_FILES_ARRAY[@]}"
    # echo "Files matching pattern:"  # Uncomment for debugging
    # echo "${UPLOAD_FILES_ARRAY[@]}"  # Uncomment for debugging
else
    echo "Error: no files found to process matching pattern"
    CURRENT_DIRECTORY=$(pwd)
    echo "Listing files in current directory: $CURRENT_DIRECTORY"
    ls -1
    if [ -d "$UPLOAD_DIRECTORY" ]; then
        echo "Listing files in upload directory: $UPLOAD_DIRECTORY"
        ls -1 "$UPLOAD_DIRECTORY"
    fi
    FAILURES=$((FAILURES+1))
    transfer_report
fi

# Convert separate parameters (if specified) into NEXUS_URL variable
if [[ -n ${NEXUS_SERVER+x} ]] && [[ -n ${NEXUS_REPOSITORY+x} ]]; then
    NEXUS_URL="https://$NEXUS_SERVER/repository/$NEXUS_REPOSITORY/"
fi

if [ -z ${NEXUS_URL+x} ]; then
    echo "ERROR: Specifying the upload/repository URL is mandatory"; exit 1
fi

# Don't accept partial or unencrypted URLs, check for HTTPS prefix
if [[ ! "$NEXUS_URL" == "https://"* ]]; then
    echo "Error: Nexus server must be specified as a secure URL"; exit 1
fi

# Prompt for credentials if not specified explicitly or present in the shell environment
if [ -z ${NEXUS_USERNAME+x} ]; then
    echo -n "Enter username: "
    read -r NEXUS_USERNAME
    if [[ -z "$NEXUS_USERNAME" ]]; then
        echo "ERROR: Username cannot be empty"; exit 1
    fi
fi
if [ -z ${NEXUS_PASSWORD+x} ]; then
    echo -n "Enter password: "
    read -s -r NEXUS_PASSWORD  # Does not echo to terminal/console
    echo ""
    if [[ -z "$NEXUS_PASSWORD" ]]; then
        echo "ERROR: Password cannot be empty"; exit 1
    fi
fi

CREDENTIALS="$NEXUS_USERNAME:$NEXUS_PASSWORD"

# Main script entry point

echo "Uploading to: $NEXUS_URL"
process_files
transfer_report
