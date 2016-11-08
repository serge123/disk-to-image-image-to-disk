#!/bin/sh
#
# Ver 0.2
# Script to restore disk
#
# Format files, example
#
# fdisk-info.txt 						partitions info
# *-mbr.bin 							MBR
# *-mbr.bin.md5  						MBR md5sum
# *sda1.raw.gz 							1-st partition
# *sda1.raw.gz.md5 						1-st partition md5sum
# *sda2.raw.gz 							2-nd partition
# *sda2.raw.gz.md5 						2-nd partition md5sum
# and so on
#
# To Do :
# 

# Const and vars
CURDIR=`ls`

PREFIX=/dev/
SEARCHPART="/dev/..."
DISK=$PREFIX$1

MBRTXT="fdisk-info.txt"
MBRBIN="mbr.bin"
MBRBINMD="mbr.bin.md5"

EXCLUD=md5

RAWGZ=".raw.gz"
RAWGZMD=".raw.gz.md5"

# Checking input disk parameter
if !(test -b $DISK) ; then 
	echo "need valid disk parameter: sda, sdb or sdc"  
	echo  
	echo "Usage: sh installing-disk.sh [DISK]"
	echo "Example: sh installing-disk.sh sda" 
	exit 0
fi

if !(test -f $MBRTXT) ; then	
	echo "file $MBRTXT is not found"
	echo "Exiting .."
	exit 0
fi

# Checking that disk is not mounted
if ( mount | grep -q $DISK ) ; then
	mount | grep $DISK 
	echo "Disk $DISK is mounted"
	echo "Unmount $DISK partitions to restore $DISK"
	exit 0	
fi

# Partitions info
echo
cat $MBRTXT
echo

# Writing MBR + Partition table 
for FILENAME in $CURDIR
do
	if (echo $FILENAME | grep -v $EXCLUD | grep -q $MBRBIN) ; then	

		echo "Found $FILENAME, seaching for MD5SUM file..."

		# Checking md5sum
		MD5FILE="NOT FOUND"
		for FILENAMEMD5 in $CURDIR
		do			
			if (echo $FILENAMEMD5 | grep -q $MBRBINMD) ; then
				MD5FILE="FOUND"
				echo "$FILENAMEMD5 found"
				echo "Checking MD5SUM of $FILENAME with $FILENAMEMD5"
				MD5SUMF=`cat $FILENAMEMD5`
				MD5SUMCHECK=`md5sum $FILENAME`
				if [ "$MD5SUMF" == "$MD5SUMCHECK" ] ; then
					echo "MD5SUM is OK."
					echo "dd if=$FILENAME of=$DISK bs=512 count=1"
					dd if=$FILENAME of=$DISK bs=512 count=1
					break
				else 
					echo "MD5SUM is diffierent. $FILENAME is corrupted."
					echo "Exiting .."
					exit 0
				fi
			fi
		done

		if [ "$MD5FILE" == "NOT FOUND" ] ; then
			echo "MD5SUM file for $FILENAME is not found. "
			echo "Exiting .."
			exit 0
		fi
		echo 
		break

	fi

done

# Writing partitions
for i in {1..9}
do

	for FILENAME in $CURDIR
	do
		if (echo $FILENAME | grep -v $EXCLUD | grep -q $i$RAWGZ) ; then
		
			echo "Found $FILENAME, seaching for MD5SUM file..."
			
			# Checking md5sum
			MD5FILE="NOT FOUND"
			for FILENAMEMD5 in $CURDIR
			do			
				if (echo $FILENAMEMD5 | grep -q $i$RAWGZMD) ; then
					MD5FILE="FOUND"
					echo "$FILENAMEMD5 found"
					echo "Checking MD5SUM of $FILENAME with $FILENAMEMD5"
					MD5SUMF=`cat $FILENAMEMD5`
					MD5SUMCHECK=`md5sum $FILENAME`
					if [ "$MD5SUMF" == "$MD5SUMCHECK" ] ; then
						echo "MD5SUM is OK."					
						# Reading argument for partition
						PARTSTART=`cat $MBRTXT | grep "$SEARCHPART$i" | awk '{print $2}'`
						# Checking that PARTSTART got Start column value, not Boot column value. Boot value is mark as * 							
						if [ "$PARTSTART" == "*" ] ; then
							PARTSTART=`cat $MBRTXT | grep "$SEARCHPART$i" | awk '{print $3}'`
						fi
						echo "reading partition info : start - $PARTSTART "
						echo "gunzip -c $FILENAME | dd of=$DISK bs=64M oflag=seek_bytes seek=$(($PARTSTART* 512))"
						gunzip -c $FILENAME | dd of=$DISK bs=64M oflag=seek_bytes seek=$(($PARTSTART* 512))
						break
					else 
						echo "MD5SUM is diffierent. $FILENAME is corrupted."
						echo "Exiting .."
						exit 0
					fi
				fi
			done
			
			if [ "$MD5FILE" == "NOT FOUND" ] ; then
				echo "MD5SUM file for $FILENAME is not found. "
				echo "Partition will be not restored"
				echo "Exiting .."
				exit 0
			fi
			echo 
			break
		fi
	done

done

echo "Finished, restart PC .."
