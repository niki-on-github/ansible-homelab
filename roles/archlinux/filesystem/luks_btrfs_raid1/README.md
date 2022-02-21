# LUKS + BTRFS RAID1

RAID1 gives us more security and helps when bitrot happens. In such a case the filesystem detects errors in data blocks by using checksums. If we have a RAID1 configuration the filesystem corrects the defective block by using the sibling on the other disk.

## Monitoring

To see an overall status of a btrfs volume we can use:

```bash
sudo btrfs-status /path/to/an/mounted/btrfs-volume
```

## Maintenance

To keep your btrfs volume clean and ensure data integrity you should execute scrubbing and balancing once per year.

### Scrubbing

This checks all checksums and corrects possible errors by using redundant copy from an btrfs RAID1 configuration. If no RAID1 configuration exists an error is printed. This is the main mechanism against bitrot. This process needs a long time and is really I/O heavy!

Scrubbing control commands:

```bash
sudo btrfs scrub start /path/to/an/mounted/btrfs-volume
sudo btrfs scrub status /path/to/an/mounted/btrfs-volume
sudo btrfs scrub cancel /path/to/an/mounted/btrfs-volume
sudo btrfs scrub resume /path/to/an/mounted/btrfs-volume
```

### Balancing

Commands to rebalance blocks (data/metadata) with less then 80% usage:

```bash
sudo btrfs balance start -dusage=80 /path/to/an/mounted/btrfs-volume
sudo btrfs balance start -musage=80 /path/to/an/mounted/btrfs-volume

```

## Replace failed disk

See: [Using Btrfs with Multiple Devices](https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices#Replacing_failed_devices)
