#!/bin/sh
# Ver 0.2
# Script to backup disk

# Format files, example
#
# fdisk-info.txt						partitions info
# *-mbr.bin 							MBR
# *-mbr.bin.md5  						MBR md5sum
# *sda1.raw.gz 							1-st partition
# *sda1.raw.gz.md5 						1-st partition md5sum
# *sda2.raw.gz 							2-nd partition
# *sda2.raw.gz.md5 						2-nd partition md5sum
# and so on
#
# Logical disks such as sda5, sda6 ... will be not stored separate 
# They will be included to extended partition  
#
# To Do :
# 

# Const and vars
PREFIX=/dev/
DISK=$PREFIX$1
POSTFIX="-"
FILENAMEPREFIX=$2$POSTFIX

MBRTXT="fdisk-info.txt"
MBRBIN="mbr.bin"
MBRBINMD="mbr.bin.md5"
fdisk -l $DISK > $MBRTXT
EXTENDED="Ext" # to recognize Extended partition in MBRTXT file

RAW=".raw"
RAWGZ=".raw.gz"
RAWGZMD=".raw.gz.md5"

# Checking input disk parameter
if !(test -b $DISK) ; then 
	echo "need valid disk parameter: sda, sdb or sdc"
	echo  
	echo "Usage: sh backup-disk.sh [DISK] [FILENAME]"
	echo "Example: sh backup-disk.sh sda xpe-backup"
	exit 0
fi

# Checking input filename parameter
if !(test $2) ; then 
	echo "need valid filename parameter."  
	echo  
	echo "Usage: sh backup-disk.sh [DISK] [FILENAME]"
	echo "Example: sh backup-disk.sh sda xpe-backup"
	exit 0
fi

# Checking that disk is not mounted
if ( mount | grep -q $DISK ) ; then
	mount | grep $DISK 
	echo "Disk $DISK is mounted"
	echo "Unmount $DISK partitions to backup $DISK"
	exit 0	
fi

# Partitions info
echo
cat $MBRTXT
echo

# MBR + Partition table backup
echo "Saving mbr sector with dd if=$DISK of=$FILENAMEPREFIX$MBRBIN bs=512 count=1"
dd if=$DISK of=$FILENAMEPREFIX$MBRBIN bs=512 count=1
echo "Calculating MD5 with md5sum $FILENAMEPREFIX$MBRBIN > $FILENAMEPREFIX$MBRBINMD "
md5sum $FILENAMEPREFIX$MBRBIN > $FILENAMEPREFIX$MBRBINMD

# Partitions backup
for i in {1..9}
do
	if (test -b $DISK$i) ; then 
		if ( cat $MBRTXT | grep -q $DISK$i); then
			# Reading arguments for partition
			PARTSTART=`cat $MBRTXT | grep $DISK$i | awk '{print $2}'`
			# Checking that PARTSTART got Start column value, not Boot column value. Boot value is mark as *
			if [ "$PARTSTART" == "*" ] ; then
				PARTSTART=`cat $MBRTXT | grep $DISK$i | awk '{print $3}'`
				PARTEND=`cat $MBRTXT | grep $DISK$i | awk '{print $4}'`
			else
				PARTEND=`cat $MBRTXT | grep $DISK$i | awk '{print $3}'`
			fi
			echo "reading partition info : start - $PARTSTART  end - $PARTEND"
			PARTLEN=$((PARTEND-PARTSTART+1))
			# Saving partition, compressing and calculating md5sum
			echo "Saving partition with dd if=$DISK of=$FILENAMEPREFIX$1$i$RAW bs=64M iflag=skip_bytes,count_bytes skip=$(($PARTSTART*512)) count=$(($PARTLEN*512))"
			dd if=$DISK of=$FILENAMEPREFIX$1$i$RAW bs=64M iflag=skip_bytes,count_bytes skip=$(($PARTSTART*512)) count=$(($PARTLEN*512))
			echo "Compressing partition with gzip -9 $FILENAMEPREFIX$1$i$RAW"
			gzip -9 $FILENAMEPREFIX$1$i$RAW
			echo "Calculating MD5 with md5sum $FILENAMEPREFIX$1$i$RAWGZ > $FILENAMEPREFIX$1$i$RAWGZMD"
			md5sum $FILENAMEPREFIX$1$i$RAWGZ > $FILENAMEPREFIX$1$i$RAWGZMD
			#Exiting if partition is extended
			if ( cat $MBRTXT | grep $DISK$i | grep $EXTENDED ); then
				echo "Extended partition detected: $DISK$i"
				break
			fi 		
		fi
	fi
done

ls -l | grep $FILENAMEPREFIX

echo "Finished .."
