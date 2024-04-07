#!/usr/bin/env bash

clear
#greating the user and printing menu
echo "Welcome to files integrity checker"
echo "Choose an option"
echo " "
echo "1- Make baseline"
echo "2- Check files integrity aginst baseline"
echo "q- Quit"

read option

#checking user input
while [ true ]
do
	case "$option" in
		"1") echo "Enter the directory name to make baseline"
		     read dir
		     ./Baseline_generator.sh "$dir"
		   ;;

		"2") echo "Enter the directory name to check integrity"
		   read dir
		   ./integrity_checker.sh "$dir"
		   ;;

		"q") exit 0;;

		*) echo "Invalid input try again!";;
	esac
#reprinting the menu
clear
echo "Choose an option"
echo " "
echo "1- Make baseline"
echo "2- Check files integrity aginst baseline"
echo "q- Quit"

read option

done
