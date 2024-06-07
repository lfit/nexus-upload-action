# Nexus Upload Tools

Script to automate the upload of files to Nexus servers

- [Source Code in Gerrit](https://gerrit.linuxfoundation.org/infra/admin/repos/releng/nexus-upload,general)
- [Source Code on GitHub](https://github.com/lfit/releng-nexus-upload)

## Nexus Upload Shell Script

### Getting Started

Make sure the script is executable on your system

```console
chmod a+x nexus-upload.sh
```

Help is available directly from the command-line:

```console
./nexus-upload.sh -h
Usage: nexus-upload.sh [-h] -r repository -d directory [-e file extension]
    -h  display this help and exit
    -r  remote repository name (mandatory)
    -d  local directory of files to upload (mandatory)
    -e  match file extension (optional)
```

The script looks for a cURL configuration file in the current working directory called:

```console
.netrc
```

This should contain the Nexus server name, and a username and password providing write access to the repository.

Here's an example of the required file content:

```console
machine [nexus-server]
  login [nexus-username]
  password [nexus-password]
```

A local folder containing files to upload is mandatory with the "-d" flag. If no file extensions are
specified, then the default is wildcard (\*) file matching behaviour. You can prevent this, by
specifying an extension restricting the files to be uploaded using the "-e" flag.

## Nexus Upload GitHub Action

This repository also contains a GitHub Action to upload files to Sonatype Nexus servers.

### Inputs/Outputs

**Required inputs:**

- nexus_username
- nexus_password
- nexus_server
- nexus_repository
- upload_directory

**Optional inputs:**

- filename_suffix
<!--
  # May be superfluous parameter
- repository_format
  -->

**Outputs:**

- errors [ true | false ]
- successes [ numeric value ]
- failures [ numeric value ]

### Usage Example

```yaml
---
name: "Nexus Upload"

on:
  workflow_dispatch:

jobs:
  upload-files:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: "Nexus Upload"
      uses: lfit/releng-nexus-upload@v1 # Release version
      with:
        nexus_server: nexus3.example.org
        nexus_username: upload-test
        nexus_password: ${{ secrets.nexus_password }} # Repository secret
        nexus_repository: testing
        upload_directory: files
        filename_suffix: .txt # Optional
```

<!--
      # Removed from the above console output
      repository_format: raw # Not implemented yet (may be superfluous)
-->

<!--
[comment]: # SPDX-License-Identifier: Apache-2.0
[comment]: # Copyright 2024 The Linux Foundation <matthew.watkins@linuxfoundation.org>
-->
