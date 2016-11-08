# Disk backup/restore bash scripts

    Disk backup/restore scripts are based on dd utility. 
    It is recommended to shrink partitions before to start backup. 
    Shrinking disk partitions might significantly reduce time to backup disk. 
    It can be used any Linux live CD/USB storage to run scripts.
    RAW output files like *-sda1.raw and *-sda2.raw (see example below, it needs to unpack) 
    can be mounted with Linux mount utility.

Scripts:

    - backup-disk.sh        backup disk
    
        Usage: sh backup-disk.sh [DISK] [FILENAME]
        Example: sh backup-disk.sh sda xpe-backup

    - installing-disk.sh    restore disk

        Usage: sh installing-disk.sh [DISK]
        Example: sh installing-disk.sh sda


Files are created with backup-disk-testing.sh, example:

    - fdisk-info.txt      partitions info (fdisk -l /dev/sda > fdisk-info.txt)
    - *-mbr.bin           MBR + partition table
    - *-mbr.bin.md5       *-mbr.bin file md5sum
    - *-sda1.raw.gz       1-st partition
    - *-sda1.raw.gz.md5   *-sda1.raw.gz file md5sum
    - *-sda2.raw.gz       2-nd partition
    - *-sda2.raw.gz.md5   *-sda2.raw.gz file md5sum
    - and so on
    
    * is [FILENAME], see above how to use backup-disk.sh for details 


Logical disks such as sda5, sda6 ... will be not stored separate with backup-disk.sh. They will be included to extended partition (it is usually sda2) 
