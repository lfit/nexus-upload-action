# Sonatype Nexus File Upload

Automates the upload of files/artefacts from GitHub Actions to Sonatype Nexus servers

- [Source Code on GitHub](https://github.com/ModeSevenIndustrialSolutions/nexus-upload-action)

## Sonatype Nexus Upload GitHub Action

This repository contains a GitHub Action to upload files to Sonatype Nexus servers.

The action looks for a cURL configuration file in the current working directory called:

```console
.netrc
```

This should contain the Nexus server name, along with credentials providing write access to the repository.

Here's an example of the configuration file content/format:

```console
machine [nexus-server]
  login [nexus-username]
  password [nexus-password]
```

NOTE: respect the indentation of the second and third lines in the example above

A local folder containing the files to upload is mandatory. If no file extensions are specified,
then the default behaviour is wildcard (\*) file matching. You can prevent this, by specifying
a file suffix/extension restricting the files to be uploaded to a subset of the folder content.

### Action Inputs/Outputs

#### Mandatory Inputs

- nexus_username
- nexus_password
- nexus_server
- nexus_repository
- upload_directory

#### Optional Inputs

- filename_suffix
- testing [ true | false ]

When testing is set to "true" an upload directory and sample text file (with a date/time stamp)
will automatically be created. This prevents the need to create test data or add files directly
to your repository when testing the action.

<!--
  # May be superfluous parameter
- repository_format
  -->

#### Outputs

- errors [ true | false ]
- successes [ numeric value ]
- failures [ numeric value ]

### Usage Example

An example workflow has been provided that can be invoked on demand:

[.github/workflows/test.yaml](https://github.com/ModeSevenIndustrialSolutions/nexus-upload-action/blob/main/.github/workflows/test.yaml)

### Further Testing

A shell script has also been provided, along with a setup file. The shell script acts as
a thin wrapper, extracting the functional shell code from the YAML file, then running it.
The supplementary setup file provides the required parameters that would otherwise be
pass as inputs by a workflow. You still need to create a .netrc file to configure the
environment with the nexus server and credentials providing write access to the repository.

<!--
[comment]: # SPDX-License-Identifier: Apache-2.0
[comment]: # Copyright 2024 The Linux Foundation <matthew.watkins@linuxfoundation.org>
-->
