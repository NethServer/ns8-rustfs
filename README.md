# ns8-rustfs

[RustFS](https://rustfs.com/) is a distributed object storage system written in Rust.

## Install

Instantiate the module with:

    add-module ghcr.io/nethserver/rustfs:latest 1

The output of the command will return the instance name.
Output example:

    {"module_id": "rustfs1", "image_name": "rustfs", "image_url": "ghcr.io/nethserver/rustfs:latest"}

## Configure

Let's assume that the rustfs instance is named `rustfs1`.

Launch `configure-module`, by setting the following parameters:
- `host_server`: rustfs API server host name
- `host_console`: rustfs UI server host name
- `lets_encrypt`: enable or disable Let's Encrypt certificate
- `user`: rustfs admin user name, default to `rustfsadmin` (optional)
- `password`: rustfs admin user password, default to `rustfsadmin` (optional)

Example:

    api-cli run module/rustfs1/configure-module --data '{"host_server": "myrustfs.example.org", "host_console": "console.myrustfs.example.org", "lets_encrypt": true}'

The above command will:
- start and configure the rustfs instance: default root credentials `rustfsadmin`:`rustfsadmin`
- configure traefik to access rustfs with a valid Let's Encrypt certificate

Send a test HTTP request to the rustfs backend service:

    curl https://myrustfs.example.org

### Use rustfs as NS8 backup storage

You can configure a NS8 machine to backup data to a rustfs bucket.

First, create a bucket. You can do from the UI or using the command line, eg:
```
curl  https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
chmod a+x /usr/local/bin/mc
mc alias set rustfs https://myrustfs.example.org rustfsadmin rustfsadmin --api S3v4
mc mb rustfs/test1
```

Use the UI to create a generic S3 backup repository and schedule a backup for it.

### Use an external disk as rustfs storage

Rustfs supports using multiple storage volumes. If your system administrator has provisioned an additional 
volume (for example, an extra disk mounted somewhere on the filesystem), you can choose that volume as the 
Rustfs storage location during installation.

### Migrate data from a minio bucket to a rustfs bucket

If you create an NS8 rustfs backup destination, don't forget to use the data encryption key from the minio backup to be able to read the backup content.

If rustfs and minio are running on the same node, the minio FQDN needs to resolve to the Wireguard IP to be reachable. This can be achieved by adding the minio FQDN to `/etc/hosts`.

The Wireguard IP can be found at the Nodes page, in the following example the default of `10.5.4.1` is used.
For example, when the minio FQDN is `minioapi.example.com`, add the following line to `/etc/hosts`:

`10.5.4.1 minioapi.example.com`

Please remove the line after the migration to avoid future issues.

Enter rustfs environment:

    runagent -m rustfs1

Download CLI tool from [GitHub](https://github.com/rustfs/cli/releases):

    curl -L --output rustfs-cli.tar.gz "https://github.com/rustfs/cli/releases/download/v0.1.3/rustfs-cli-linux-amd64-v0.1.3.tar.gz"

Extract CLI tool:

    tar -xzf rustfs-cli.tar.gz

The archive contains a single binary named `rc`, which is the RustFS CLI executable.

Copy the tool into the rustfs container:

    podman cp rc rustfs:/usr/local/bin/

Enter rustfs container:

    podman exec -ti rustfs bash

Set rustfs alias:

    rc alias set rustfs http://localhost:9000 <RUSTFS_ACCESS_KEY> <RUSTFS_SECRET>

Set minio alias:

    rc alias set minio https://minioapi.example.com <MINIO_ACCESS_KEY> <MINIO_SECRET>

Test:

    rc mirror --dry-run minio/testbucket rustfs/testbucket

Migration:

    rc mirror minio/testbucket rustfs/testbucket

Exit container:

    exit

Cleanup:

    rm -f rc rustfs-cli.tar.gz

### Backup

To avoid inconsistencies, do not backup rustfs itself while other backups to the rustfs storage are running.

## Uninstall

To uninstall the instance:

    remove-module --no-preserve rustfs1

## Running tests locally

This module uses the NS8 standard testing infrastructure. For instructions on how to run the test suite locally, refer to the [Running tests locally](https://github.com/NethServer/ns8-github-actions/blob/v1/README.md#running-tests-locally) section of ns8-github-actions.

## UI translation

Translated with [Weblate](https://hosted.weblate.org/projects/ns8/).

To setup the translation process:

- add [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- add your repository to [hosted.weblate.org]((https://hosted.weblate.org) or ask a NethServer developer to add it to ns8 Weblate project
