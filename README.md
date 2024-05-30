# Nexus Upload

GitHub Action to upload files to Sonatype Nexus Repository servers.

Relies on the script located in the repository here:

<https://github.com/lfit/releng-nexus-upload>

**Required inputs**

- nexus_username
- nexus_password
- nexus_server
- nexus_repository

**Optional inputs**

- file_extension
- upload_directory
- repository_format

**Outputs**

- upload-status [ success | failure ]

## Usage Example

```yaml
---
name: "Nexus Upload"

on:
  workflow_dispatch:

jobs:
  publish:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: "Nexus Upload"
      uses: ModeSevenIndustrialSolutions/nexus-upload-action@v1
      with:
      nexus_server: nexus3.o-ran-sc.org
      nexus_username: admin
      nexus_password: ${{ secrets.nexus_password }} # Repository secret
      nexus_repository: datasets
      repository_format: raw # Optional
      file_extension: txt # Optional
      upload_directory: files # Optional
```

<!--
[comment]: # SPDX-License-Identifier: Apache-2.0
[comment]: # Copyright 2024 The Linux Foundation <matthew.watkins@linuxfoundation.org>
-->
