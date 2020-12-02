#!/bin/bash

#===============================================================================
#
#          file: 18-disable-user.sh
#
#         usage: ${0} [-d] [-r] [-a] user ...
#
#   description: this script disables, deletes, and/or archives users on the
#				 local system.
#        author: Luca Berni
#  organization: ins pedralbes
#       created: 23/11/2020 08:53:24 am
#      revision:  ---
#===============================================================================

# Checks if user is root
isRoot() {
	userId=$(id -u)
	if [ $userId != "0" ]
	then
		echo -e "\n\nYou are not ROOT.\nExiting...\n"
		exit 1
	fi
}

#Display the usage and exit
usage() {
  echo "Usage: ${0} [-d] [-r] [-a] USER ..." >&2
  echo 'disable/remove/backup a local Linux account.' >&2
  echo '  -d  Disable account' >&2
  echo '  -r  Remove the account' >&2
  echo '  -a  Creates an archive of the home directory associated with the account(s).' >&2
  exit 1
}

# Proper user?: not exists or account id is at least 1000.
export args=$@
checkUser(){
	export USER=$(echo "$args" | rev | cut -d ' ' -f 1 | rev)
	export userExists=0
	userId=$(id $USER | cut -d '=' -f2 | cut -d '(' -f1)
	if [ "$userId" == "" ]
	then
		userId=0
	else
		userId=$(($userId))
	fi
	export userDir=$(grep ^$USER /etc/passwd | cut -d ':' -f 6)
# DEBUG
#	echo "User: $USER"
#	echo "User dir: $userDir"
#	echo "Args: $args"
#	echo "userId: $userId"

	if [ $userId -ge 1000 ] 2>/dev/null
	then
		userExists=1
	fi
#	echo "userExists? $userExists"
}

# This function sends a message to syslog and to standard output if VERBOSE is true.
log() {
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
  logger -t luser-demo10.sh "${MESSAGE}" #pots veure missatge: tail -1 /var/log/syslog
}

# This function creates a backup of a directory.  Returns non-zero status on error.
backup_dir() {
  echo "Comenca backup de ${1}"
  local DIR=`eval echo ${1}`
  # Make sure the file exists.
  if [[ -d "${DIR}" ]]
   then
    echo "Es un directori"
    local BACKUP_FILE="/archives/$(basename ${DIR}).$(date +%F-%N)"
    log "Backing up ${DIR} to ${BACKUP_FILE}."
	if [ ! -d "/archives" ]; then
		`mkdir /archives`
    fi
    # The exit status of the function will be the exit status of the cp command.
    tar -cvf $BACKUP_FILE.tar ${DIR}
  else
    # The file does not exist, so return a non-zero exit status.
    echo NO existeix
    return 1
  fi
}

# Run as root.
isRoot

# Check if user exists
checkUser

#Parse the options
while getopts "d:r:a:" o 2>/dev/null;
do
    # OPTIND és variable interna de  getops, índex
    #echo "OPTIND: $OPTIND OPTARG: $OPTARG"
    case "${o}" in
	# OPTARG és una variable pròpia de getops i va canviant a cada
	# iteració: representa el valor l'opció que està tractant
        d)
            USERdisable=$OPTARG
              # Make sure the UID of the account is at least 1000.
			if [ $userExists == "1" ]
			then
		      		# desabilita usuari
				echo "Deshabilitant usuari..."
				usermod -L -s /bin/nologin $USER
				echo "$(grep $USER /etc/passwd)"

				#comprova usuari deshabilitat
				if [ $(passwd --status $USER | cut -d ' ' -f 2) == "L" ] 2>/dev/null
				then
					echo "Usuari deshabilitat"
				fi
			fi

            ;;
        r)
		USERremove=$OPTARG
#		echo "userExists: $userExists"
		# Make sure the UID of the account is at least 1000.
		if [ $userExists == "1" ]
		then
			# elimina usuari
			userdel $USER

			# Check user is deleted.
			if [ $(grep -o ^$USER /etc/group | sort -u) == "$USER" ] 2>/dev/null
			then
				echo "Usuari eliminat"
			fi
		fi
		;;
	a)
	    USERbackup=$OPTARG
	        # Make sure the UID of the account is at least 1000.
		if [ $userExists == "1" ]
		then
	        # crida a la funcio que fa el backup de la home de l'usuari
			backup_dir $userDir
		fi
            ;;


	# entra aquí quan s'introdueix opció però no pas argument, sent aquest
	# obligatori
        :)
            echo "ERROR: Option -$OPTARG requires an argument"
            usage
            ;;
	#entra aqui quan l'opció no és vàlida
        \?)
            echo "ERROR: Invalid option -$OPTARG"
            usage
            ;;
    esac
done
# Quan es crida l'script sense cap opció o parametre
#-z string True if the string is null (an empty string)
if [ -z $USERdisable ] && [ -z $USERremove ] && [ -z $USERbackup ]; then
    echo "Sense cap opció o paràmetre"
    usage
fi


#===============================================================================
#          CHECK TESTS ASCIINEMA
#===============================================================================
# 1- Cap opció ni paràmetre: sudo ./18-disable-user.sh
# 2- Amb opció correcta sense paràmetre: sudo ./18-disable-user.sh -d
# 3- Usuari no existent: sudo ./18-disable-user.sh -d fdsfs
# 4- Usuari id inferior a 1000: sudo ./18-disable-user.sh -d mail
# 5- Usuari a esborrar:  sudo cat /etc/shadow|grep u1
#						sudo ./18-disable-user.sh -r u1
#                       sudo cat /etc/shadow|grep u1
# 6- Usuari a deshabilitar: sudo cat /etc/shadow|grep u3
#						   sudo ./18-disable-user.sh -d u3
#                          sudo cat /etc/shadow|grep u3
# 7- Usuari a fer backup la home usuari: sudo cat /etc/shadow|grep u3
#										 sudo ./18-disable-user.sh -a u3
#										 sudo ls -la /archives


#REPRODUCCIÓ DEL TEST
#osboxes@osboxes:~/Documents$ #1
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh
#[sudo] password for osboxes: 
#Sense cap opció o paràmetre
#Usage: ./18-disable-user.sh [-d] [-r] [-a] USER ...
#Disable/delete/backup a local Linux account.
  #-d  Disable account
  #-r  Remove the account
  #-a  Creates an archive of the home directory associated with the account(s).
#osboxes@osboxes:~/Documents$ #2
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -d
#OPTIND: 2 OPTARG: d
#ERROR: Option -d requires an argument
#Usage: ./18-disable-user.sh [-d] [-r] [-a] USER ...
#Disable/delete/backup a local Linux account.
  #-d  Disable account
  #-r  Remove the account
  #-a  Creates an archive of the home directory associated with the account(s).
#osboxes@osboxes:~/Documents$ #3
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -d dfsdfds
#OPTIND: 3 OPTARG: dfsdfds
#id: ‘dfsdfds’: no such user
#osboxes@osboxes:~/Documents$ #4
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -d mail
#OPTIND: 3 OPTARG: mail
#userid: 8
#Refusing to remove the mail account with UID 8 under 1000.
#No es possible
#osboxes@osboxes:~/Documents$ #5
#osboxes@osboxes:~/Documents$ sudo cat /etc/shadow|grep u1
#u1:$6$o0buMgX79TFlVdj5$eFqxXiGaz7bV4rAAHOUS3LIwKItuwRXGDzmbTMb2siGE4N/cN9GKqVJuA7KoQOpHmXmikxccFf4EsGmvsFpSe/:18590:0:99999:7:::
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -r u1
#OPTIND: 3 OPTARG: u1
#userid: 1001
#osboxes@osboxes:~/Documents$ sudo cat /etc/shadow|grep u1
#osboxes@osboxes:~/Documents$ #6
#osboxes@osboxes:~/Documents$ sudo cat /etc/shadow|grep u3
#u3:$6$9ry09oFBmDW3L1pK$JCArZuWfrNdftEAMOjWbcs/0h.NHZnR/oLcTEaS4RzLUDqiVqAGGkpiuMJLf3XvkuyNFdRNrpwojS868StHqM1:18552:0:99999:7:::
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -d u3
#OPTIND: 3 OPTARG: u3
#userid: 1003
#Usuari deshabilitat
#osboxes@osboxes:~/Documents$ sudo cat /etc/shadow|grep u3
#u3:!$6$9ry09oFBmDW3L1pK$JCArZuWfrNdftEAMOjWbcs/0h.NHZnR/oLcTEaS4RzLUDqiVqAGGkpiuMJLf3XvkuyNFdRNrpwojS868StHqM1:18552:0:99999:7:::
#osboxes@osboxes:~/Documents$ #7
#osboxes@osboxes:~/Documents$ sudo cat /etc/shadow|grep u3
#u3:!$6$9ry09oFBmDW3L1pK$JCArZuWfrNdftEAMOjWbcs/0h.NHZnR/oLcTEaS4RzLUDqiVqAGGkpiuMJLf3XvkuyNFdRNrpwojS868StHqM1:18552:0:99999:7:::
#osboxes@osboxes:~/Documents$ sudo ./18-disable-user.sh -a u3
#OPTIND: 3 OPTARG: u3
#Comenca backup de /home/u3
#Es un directori
#tar: Removing leading `/' from member names
#/home/u3/
#/home/u3/.bashrc
#/home/u3/.profile
#/home/u3/.bash_logout
#osboxes@osboxes:~/Documents$ sudo ls -la /archives/
#total 56
#drwxr-xr-x  2 root root  4096 Nov 24 06:54 .
#drwxr-xr-x 21 root root  4096 Nov 24 05:04 ..
#-rw-r--r--  1 root root 10240 Nov 24 05:04 u2.2020-11-24-334614474.tar
#-rw-r--r--  1 root root 10240 Nov 24 05:04 u2.2020-11-24-446121658.tar
#-rw-r--r--  1 root root 10240 Nov 24 06:54 u3.2020-11-24-662481156.tar
#-rw-r--r--  1 root root 10240 Nov 24 06:16 u3.2020-11-24-749796076.tar
