#!/bin/bash

isRoot() {
	if [ $(id -u) != "0" ]
	then
		echo -e "\n\nYou are not ROOT.\nExiting...\n
		exit 1
	fi
}

isFirstArgumentSet(){
	if [ -n "$1"]
	then
		
	else
		echo "Frist parameter not supplied."
		exit 1
	fi
}

username=$1
userSuername=$2

id -u $username 2> /dev/null
if [ $? -eq 1 ]
then
	case $2 in
	
	"")
		useradd $username
		;;
	*)
		useradd -c $fullName $username
		;;
	esac	
	
	if [ $? -eq 0 ]
	then
		usermod -p $password $username
		if [ $? -eq 0 ]
		then
			passwd --expire $username
			echo -e `grep -i :$username: /etc/passwd` "\npass: $password"
		else 
			echo "ERROR: Password has not been established"
		fi
	else
		echo "ERROR: Creation proccess of user $username has gone wrong"
		exit $?
	fi
else
	echo "ERROR: User already exists"
fi
