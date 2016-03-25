#/bin/bash
#########################################
#Function:    auto parted disk
#Author:      Jason.z(www.jason-z.com)
#Version:     1.0
#########################################

# which disk shoule be parted
disk=/dev/vdc

# disk type
fstype=ext4

# partition num
num=3

# partition size(rate)
sizes=(0.3 0.3 0.4)

# partition mount folders(rate)
folders=(/data /db /backup)


if [ ${#sizes[@]} != ${num} ];then
	echo "partition sizes configure error!"
	exit
fi

if [ ${#folders[@]} != ${num} ];then
	echo "mount folders configure error!"
	exit
fi

# get
disk_size=$(fdisk -s ${disk})

umount ${disk}*

fdisk_fun()
{
fdisk -S 56 ${disk} << EOF
n
p
${1}

${2}
wq
EOF

sleep 5
mkfs -t ${fstype} ${disk}${1}
}

temp=0

for((i=0;i<${num};i++));do
	if [ ${i} -lt ${num} ] ;then
		cyfinder=$(echo ${sizes[${i}]}*${disk_size}/512 | bc)
		fdisk_fun $(( ${i} + 1 )) $(( ${cyfinder} + $temp ))
		let temp+=${cyfinder}
	else 
		fdisk_fun ${i} 
	fi
done


for f in ${folders[@]};do
	if [ ! -d ${f} ];then
		mkdir -p ${f}
	fi
done

for((i=0;i<${num};i++));do
	echo "${disk}$(( $i + 1 ))  ${folders[${i}]}  ${fstype}    defaults    0  0" >> /etc/fstab
done


mount -a
 
