# Disk backup/restore bash scripts

Scripts:

    - backup-disk-testing.sh        backup disk
    
        Usage: sh backup-os.sh [DISK] [FILENAME]
        Example: sh backup-os.sh sda xpe-backup

    - installing-disk-testing.sh    restore disk

        Usage: sh installing-os.sh [DISK]
        Example: sh installing-os.sh sda


Format files, example:

    - fdisk-info.txt      partitions info (fdisk -l /dev/sda > fdisk-info.txt)
    - *-mbr.bin           MBR + partition table
    - *-mbr.bin.md5       MBR md5sum
    - *sda1.raw.gz        1-st partition
    - *sda1.raw.gz.md5    1-st partition md5sum
    - *sda2.raw.gz        2-nd partition
    - *sda2.raw.gz.md5    2-nd partition md5sum
    - and so on

Logical disks such as sda5, sda6 ... will be not stored separate. They will be included to extended partition  
