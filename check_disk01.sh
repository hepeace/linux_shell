#!/bin/bash
#check disk no raid and post error information.
	read -p "Please Input The Error Disk:" disk
df -h | grep -Evi 'shm|filesystem' |awk '{print $1"\t"$2"\t"$6}' > /tmp/mount.txt
     cat /tmp/mount.txt | while read line ;do
	 part1=$(echo $line | awk '{print $1}' | awk -F"/" '{print $3}')
	 part2=$(echo $line | awk '{print $2}')
	 part3=$(echo $line | awk '{print $3}')
	 ex2id=$(echo "$part3" | tr -d 'a-z' | tr -d '/')
	 ex1id=$[ $ex2id - 1 ]
	 ex1id_length=${#ex1id}
	 ex1size=$(echo "$part2" | tr -d 'A-Z')
	if [ $ex1id_length -lt 2 ];then
	     id="Id: 0$ex1id"
	else
	     id="Id: $ex1id"
	fi
	
	if [ $ex1size -gt 250 -a $ex1size -lt 450 ];then
		 size=300G
	elif [ $ex1size -gt 450 -a $ex1size -lt 1024 ];then
		size=1T
	elif [ $ex1size -gt 1024 -a $ex1size -lt 2048 ];then
		size=2T
	else
		size=$part2
	fi
disk_err_count=$(cat /tmp/dmesg | grep -ic 'error')
	 if [ "$part1" = "$disk" ] && [ $disk_err_count -gt 10 ];then
		touch /tmp/$disk.err
		echo "第$ex2id 块硬盘故障，id=$ex1id,$size " > /tmp/$disk.err
		cat /proc/scsi/scsi | grep -Evi 'attached|type' |sed 's/^  //g' |xargs -n 14 | grep -i "$id" | xargs -n 8 >> /tmp/$disk.err
	cat /tmp/dmesg |grep -i 'error' | grep -i "$disk"  | tail -10 >> /tmp/$disk.err
	fi
done
