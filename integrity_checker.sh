#!/usr/bin/env bash

integrityChecker(){
	dir_name="$1"

	#find the directory path
	dir_path=$(find / -type d -name $1 2>/dev/null | head -n1)

	#check if the directory exist
	if [ -d "$dir_path" ]
	then
		baseline_name="$1"_Baseline.txt
		if [ -f Baselines/"$baseline_name" ]
		then
			compare_file=/tmp/"$1".txt
			writeTempStatus "$dir_path"
			compare
		else
			echo "Sorry it seems that you don't have a baseline for this file please make one first"
			sleep 5
		fi
	else
		echo "Sorry there is no such file named $1"
		sleep 2
	fi
}

writeTempStatus(){

	#loops through the files in the directory and subdirctorys recursively to write the pressnt status of the files
        for i in "$1"/*
        do
                if [ -d "$i" ]
                then
                        writeTempStatus "$i"
                elif [ -f "$i" ]
                then

			#extract the content of the file and calculate the hash and append it in the format info:hash
                        content=$(ls -l $i)
                        hash=$(sha256sum $i | cut -d ' ' -f 1)
                        echo "${content}:${hash}" >> "$compare_file"
                fi
        done
}
compare(){

	#extract the number of lines in the baseline file
	num_lines=$(cat Baselines/"$baseline_name" | wc -l)

	#loop through the lines and and passing the number of the line to each compare function
	for (( j=1; j<=$num_lines; j++))
	do
		permission $j
		owner $j
		hash $j
	done

	#append each category to the report file
	echo "Alterd permissions" >> Reports/r.log
	cat /tmp/permission.txt >> Reports/r.log
	echo "--------------------------------------------------------------------------------------------" >> Reports/r.log
	echo " " >> Reports/r.log
	echo "Alterd owner" >> Reports/r.log
	cat /tmp/owner.txt >> Reports/r.log
	echo "--------------------------------------------------------------------------------------------" >> Reports/r.log
	echo " " >> Reports/r.log
	echo "Alterd content (hash)" >> Reports/r.log
	cat /tmp/hash.txt >> Reports/r.log
	cat Reports/r.log

	#rename the report file to the format dirctory name_check_YYYY-MM-DD_HH-MM-SS.log
	mv Reports/r.log Reports/"$dir_name"_check_$(date +"%Y-%m-%d_%H-%M-%S").log

	#removing the temporary files
	rm /tmp/hash.txt
	rm /tmp/owner.txt
	rm /tmp/permission.txt
	rm /tmp/"$dir_name".txt

	echo "press any key to quit log review"
	read -n1 -r -s
}

#compare the permission section between the baseline and the present status
permission(){
	permission_file=/tmp/permission.txt
	base=$(sed -n "$1 p"  Baselines/"$baseline_name" | cut -d ' ' -f 1)
	now=$(sed -n "$1 p"  "$compare_file" | cut -d ' ' -f 1)

	echo " " >> "$permission_file"
	if [ "$base" != "$now" ]
	then
		echo " " >> "$permission_file"
		echo "Before" >> "$permission_file"
		echo $(sed -n "$1 p"  Baselines/"$baseline_name") >> "$permission_file"
		echo " " >> "$permission_file"
		echo "After" >> "$permission_file"
		echo $(sed -n "$1 p" "$compare_file") >> "$permission_file"
		echo " " >> "$permission_file"
		echo "###################################################################################" >> "$permission_file"
	fi
}

#compare the owner section between the baseline and the present status
owner(){
	owner_file=/tmp/owner.txt
	user_base=$(sed -n "$1 p"  Baselines/"$baseline_name" | cut -d ' ' -f 3)
	group_base=$(sed -n "$1 p"  Baselines/"$baseline_name" | cut -d ' ' -f 4)
	user_now=$(sed -n "$1 p"  "$compare_file" | cut -d ' ' -f 3)
	group_now=$(sed -n "$1 p"  "$compare_file" | cut -d ' ' -f 4)

	echo " " >> "$owner_file"
	if [ "$user_base" != "$user_now" ] || [ "$group_base" != "$group_now" ]
	then
		echo " " >> "$owner_file"
		echo "Before" >> "$owner_file"
		echo $(sed -n "$1 p"  Baselines/"$baseline_name") >> "$owner_file"
		echo " " >> "$owner_file"
		echo "After" >> "$owner_file"
		echo $(sed -n "$1 p" "$compare_file") >> "$owner_file"
		echo " " >> "$owner_file"
		echo "###################################################################################" >> "$owner_file"
	fi
}

#compare the hash section between the baseline and the present status
hash(){
	hash_file=/tmp/hash.txt
	base=$(sed -n "$1 p"  Baselines/"$baseline_name" | cut -d ':' -f 3)
	now=$(sed -n "$1 p"  "$compare_file" | cut -d ':' -f 3)

	echo " " >> "$hash_file"
	if [ "$base" != "$now" ]
	then
		echo " " >> "$hash_file"
		echo "Before" >> "$hash_file"
		echo $(sed -n "$1 p"  Baselines/"$baseline_name") >> "$hash_file"
		echo " " >> "$hash_file"
		echo "After" >> "$hash_file"
		echo $(sed -n "$1 p" "$compare_file") >> "$hash_file"
		echo " " >> "$hash_file"
		echo "###################################################################################" >> "$hash_file"
	fi
}

integrityChecker "$1"
