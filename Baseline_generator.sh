#!/usr/bin/env bash

permission_to_make_baseline=1

makeBaseline(){
	#allocating directory path
	dir_path=$(find / -type d -name $1 2>/dev/null | head -n1)

	#check if the directory exist
	if [ -d "$dir_path" ]
	then
		#constracting the baseline file name
		baseline_name="$1"_Baseline.txt
		checkForName
		#check to know if the user have the baseline file and dont want to replace it
		if [ $permission_to_make_baseline -eq 0 ]
		then
			return
		fi
		writeBaseline "$dir_path"
	else
		echo "Sorry ther is no such file named $1"
		sleep 2
	fi
}

checkForName(){
	#check if alredy there is a baseline for the directory
	if [ -f "Baselines/$baseline_name" ]
	then
		echo "ther is a baseline for that do you want to replace it [y/n]"
		read option
		if [ "$option" == "n" ]
		then
			permission_to_make_baseline=0
		else
			permission_to_make_baseline=1
			$(> Baselines/"$baseline_name")
		fi
	fi
}

writeBaseline(){
	#loops through all the files in the directory and the subdirctorys recursively
	for i in "$1"/*
	do
		if [ -d "$i" ]
		then
			writeBaseline "$i"
		elif [ -f "$i" ]
		then
			#extracting file informations and calculating the hash value and append them to the baseline file in the formate info:hash
			content=$(ls -l $i)
			hash=$(sha256sum $i | cut -d ' ' -f 1)
			echo "${content}:${hash}" >> Baselines/"$baseline_name"
		fi
	done
}
makeBaseline "$1"
