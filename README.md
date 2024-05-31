# Nexus Upload

GitHub Action to upload files to Sonatype Nexus Repository servers.

Relies on the script located in the repository here:

<https://github.com/lfit/releng-nexus-upload>

## inputs/Outputs

**Required inputs:**

- nexus_username
- nexus_password
- nexus_server
- nexus_repository

**Optional inputs:**

- directory
- filename_suffix
<!--
  # May be superfluous parameter
- repository_format
  -->

**Outputs:**

- upload-status [ success | failure ]

## Usage Example

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
      uses: ModeSevenIndustrialSolutions/nexus-upload-action@v1
      with:
      nexus_server: nexus3.o-ran-sc.org
      nexus_username: admin
      nexus_password: ${{ secrets.nexus_password }} # Repository secret
      nexus_repository: datasets
      directory: files # Optional
      filename_suffix: txt # Optional
```

<!--
      # Removed from the above console output
      repository_format: raw # Not implemented yet (may be superfluous)
-->

<!--
[comment]: # SPDX-License-Identifier: Apache-2.0
[comment]: # Copyright 2024 The Linux Foundation <matthew.watkins@linuxfoundation.org>
-->
