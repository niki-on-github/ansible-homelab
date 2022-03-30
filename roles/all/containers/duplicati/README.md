# Duplicati

Duplicati is a backup client that securely stores encrypted, incremental, compressed remote backups of local files on cloud storage services and remote file servers.

## Stop Container before backup to avoid data inconsistency

In Point `5 Options` select the Advanced Options `run-script-before` and `run-script-after`. Then insert the paths:

- `run-script-before`: `/scripts/stop-all-containers.sh`
- `run-script-after`: `/scripts/start-all-containers.sh`
