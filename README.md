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

    api-cli run module/rustfs1/configure-module --data '{"host_server": "myrustfs.nethserver.org", "host_console": "console.myrustfs.nethserver.org", "lets_encrypt": true}'

The above command will:
- start and configure the rustfs instance: default root credentials `rustfsadmin`:`rustfsadmin`
- configure traefik to access rustfs with a valid Let's Encrypt certificate

Send a test HTTP request to the rustfs backend service:

    curl https://myrustfs.nethserver.org

### Use rustfs as NS8 backup storage

You can configure a NS8 machine to backup data to a rustfs bucket.

First, create a bucket. You can do from the UI or using the command line, eg:
```
curl  https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
chmod a+x /usr/local/bin/mc
mc alias set rustfs https://myrustfs.nethserver.org rustfsadmin rustfsadmin --api S3v4
mc mb rustfs/test1
```

Use the UI to create a generic S3 backup repository and schedule a backup for it.

### Use an external disk as rustfs storage

Rustfs supports using multiple storage volumes. If your system administrator has provisioned an additional 
volume (for example, an extra disk mounted somewhere on the filesystem), you can choose that volume as the 
Rustfs storage location during installation.

### Backup

To avoid inconsistencies, do not backup rustfs itself while other backups to the rustfs storage are running.

## Uninstall

To uninstall the instance:

    remove-module --no-preserve rustfs1

## Testing

Test the module using the `test-module.sh` script:

    ./test-module.sh <NODE_ADDR> ghcr.io/nethserver/rustfs:latest

The tests are made using [Robot Framework](https://robotframework.org/)

## UI translation

Translated with [Weblate](https://hosted.weblate.org/projects/ns8/).

To setup the translation process:

- add [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- add your repository to [hosted.weblate.org]((https://hosted.weblate.org) or ask a NethServer developer to add it to ns8 Weblate project
