#!/bin/bash

export IFS='
'
# COLORS #
red="\e[01;31m"; green="\e[01;32m"; yellow="\e[01;33m";
blue="\e[01;34m"; purple="\e[01;35m"; cyan="\e[01;36m";
end="\e[00m";
# VARIABLES CUSTOMS #
GBOX="${blue}[${green}+${blue}]${end}";
RBOX="${blue}[${red}-${blue}]${end}";
NBOX="${blue}[${cyan}*${blue}]${end}";

# SIGNAL OF CANCELED AND FAILED #
CTRL_C(){
	echo -e "${blue}---${red}PROCESS CANCELED${blue}---${end}"
	tput cnorm
	exit 0
}
FAILED(){
	echo -e "${blue}---${red}PROCESS FAILED${blue}---${end}"
	tput cnorm
	exit 0
}
# Called of the signal CTRL_C AND FAILED#
trap CTRL_C INT
trap FAILED SIGTERM

# HELP MENU #
HELP_MENU(){
	clear 
	echo -e "${blue}Use Mode${end}:\n"
	echo -e "${blue} -d \tSpecific a Directory With ZIP or RAR files.${end}"
	echo -e "${blue} -f \tSpecify a Only ZIP or RAR file.${end}"
	echo -e "${blue} -h \tShow The HELP MENU.${end}"
	echo -e "${blue}--help${end}\n"
	echo -e "${red} NOTE: This Script Only Decompress ZIP or RAR files.${end}"
}

# CHECKING OF THE DEPENDENCES#
CHECK_DEPENDENCES(){
	local route="/usr/bin"
	declare -i local count=0
	sleep 1
	listPrograms=(unzip unrar) 
	echo -e "${NBOX} ${yellow}Checking Dependences.......${end}";sleep 1
	#Iterates the list of programs#
	for program in ${listPrograms[@]}; do
     echo -e "${GBOX} ${green}${program}... ${end}\c";sleep 1
		 #Check dependences#
		 `test -f "${route}/${program}"`
		 if [[ $? -eq 0 ]]; then
			 echo -e "${green} ✔ ${end}";sleep 1
		 else
			 echo -e "${red} ✘ ${end}";sleep 1
			 let count+=1
		fi
	done
	#Check if not exit a only program for finish el script#
	if [[ ${count} -ne 0 ]]; then
		echo -e "${red}Error of the Dependences.${end}"
		FAILED
	fi
}

# CHECK FILE #
CHECK_FILE(){
	local pathFile="${1}"
	local location="${1%/*}"  #Show the lotation
	local fullName="${1##*/}" #Show the full name
	local nameFile="${fullName%.*}" #Show only the name
	local exteFile="${fullName#*.}" #Show only the extension
	sleep 1
	echo -e "${NBOX} ${yellow}Checking if exist the compress file.......${end}\c";sleep 1
	#Check if exist the file#
	if [[ -f $1 ]]; then
		#Check if the extension is valid#
		if [[ ${exteFile,,} == 'zip' || ${exteFile,,} == 'rar' ]]; then
			echo -e "${green} ✔ ${end}";sleep 1
			#Check if is a zip file#
			if [[ ${exteFile,,} == 'zip' ]]; then
				#Check if there is a directory with the same name as the file#
				echo -e "${NBOX} ${yellow}Checking that there are no duplicates${end}"
				if [[ ! -d ${location}/${nameFile} ]]; then
					echo -e "${GBOX} ${yellow}Unzipping the file ${cyan}-> ${green}${fullName}${yellow}...${end}"
					`unzip -q ${1} -d ${location}/${nameFile,,}`
					#Check if everything is ok#
					if [[ -d ${location}/${nameFile,,} ]]; then
						echo -e "${green}Sucessful decompression....!${end}"
					else
						echo -e "${red}There was an error unzipping the file, Try Again${end}"
						FAILED
					fi
				else
					echo -e "${red}Error the ${bluel}${nameFile} ${red}directory already exist,${end}"
					echo -e "${red}verify that you already have the extracted file${blue}(${red}s${blue})${end}"
					FAILED
				fi
			#Check if is a rar file#
			elif [[ ${exteFile,,} == 'rar' ]]; then
					#Check if there is a directory with the same as the file#
					echo -e "${NBOX} ${yellow}Checking the there are no duplicates${end}"
					if [[ ! -d ${location}/${nameFile} ]]; then
						`mkdir ${location}/${nameFile,,}`
						#Check if the directory was created successfully#
						if [[ $? -eq 0 ]]; then
							echo -e "${GBOX} ${yello}Unzipping the file ${cyan}-> ${green}${fullName}${yellow}...${end}"
							`unrar x ${1} ${location}/${nameFile,,} > /dev/null >&1`
							#Check if everything is ok#
							if [[ -d ${location}/${nameFile,,} ]]; then
								echo -e "${green}Sucessful decompression....!${end}"
							else
								echo -e "${red}There was an error unzipping the file, Try Again${end}"
								FAILED
							fi
					  else
							echo -e "${red}Ocurred Error to Create The Directory${end}"
							FAILED
						fi
					else
						echo -e "${red}Error the ${blue}${nameFile} ${red}directory already exist,${end}"
						echo -e "${red}verify the you already have the extracted file${blue}(${red}s${blue})${end}"
						FAILED
					fi
			fi
		else
		  echo -e "${red} ✘ ${end}";sleep 1
			echo -e "${red}The File is NOT Sopported${end}"
			FAILED
		fi
	else
		echo -e "${red} ✘ ${end}"
		echo -e "${red}This is NOT a Sopported file${end}"
		FAILED
	fi
}

# CHECK DIRECTORY #
CHECK_DIRECTORY(){	
	local extensions=(zip rar)
	declare -i local count=0
	local pathDirectory="${1}"
	sleep 1
	#Check if is a Directory#
	if [[ -d ${pathDirectory} ]]; then
		#Checking existing files and show the total on screen
		echo -e "${purple}----------------------------------------------------${end}"
		for listExt in ${extensions[@]}; do
			declare -i local countFiles=$(find ${pathDirectory} -maxdepth 1 -type f -iname "*.${listExt}" | wc -l)
			echo -e " ${blue}(${green}${countFiles}${blue})${cyan}-> ${green}${listExt^^} ${yellow}File${blue}(${yellow}s${blue}) ${yellow}Found${end}\c"
			let count+=${countFiles}
		done
	  echo -e "\n${purple}----------------------------------------------------${end}"
		#Check if exist files in the directory#
		if [[ ${count} -ne 0 ]]; then
			#list the extension#
			for ext in ${extensions[@]}; do
				 local listed=($(find ${1} -maxdepth 1 -type f -iname "*.${ext}"))
				 #count the files listed
				 local countList=$(find ${1} -maxdepth 1 -type f -iname "*.${ext}" | wc -l)
				 #check if exist files in the directory
				 if [[ ${countList} -ne 0 ]]; then
			   	 echo -e "${NBOX} ${yellow}Unzipping everything the ${green}${ext^^} ${yellow}files${end}"
					 #listed the files"
				 	 for file in ${listed[@]}; do
					 		local switch="${file#*.}"				#Switch of mayus a min
							local location="${file%/*}"			#Show the location of the file
							local fullName="${file##*/}"		#Show the full Name
							local nameFile="${fullName%.*}"	#Show only the name
							local exteFile="${fullName#*.}"	#Show only the extension
							sleep 0.2
							#Check if is a zip or rar file
							if [[ ${switch,,} == 'zip' ]]; then
								#unzipping the zip files	
								#Check if there is a directory with the same name as the file#
								echo -e "${NBOX} ${yellow}Checking that there are no duplicates${end}"
								if [[ ! -d ${location}/${nameFile// /_} ]]; then
									echo -e "${GBOX} ${yellow}Unzipping the file ${cyan}-> ${green}${fullName}${yellow}... ${end}\c"
									`unzip -q ${file} -d ${location}/${nameFile// /_}`
									#Check if everything is ok#
									if [[ -d ${location}/${nameFile// /_} ]]; then
										echo -e "${green}Sucessful decompression....!${end}"
									else
										echo -e "${red}There was an error unzipping the file, Try Again${end}"
										FAILED
									fi
								else
									echo -e "${red}Error the ${bluel}${nameFile} ${red}directory already exist,${end}"
									echo -e "${red}verify that you already have the extracted file${blue}(${red}s${blue})${end}"
									#FAILED
								fi
							elif [[ ${switch,,} == 'rar' ]]; then
							  	#unzipping the rar fiels
								  #Check if there is a directory with the same as the file#	
									echo -e "${NBOX} ${yellow}Checking the there are no duplicates${end}"
									if [[ ! -d ${location}/${nameFile// /_} ]]; then #
										`mkdir ${location}/${nameFile// /_}` #
										#Check if the directory was created successfully#
										if [[ $? -eq 0 ]]; then
											echo -e "${GBOX} ${yellow}Unzipping the file ${cyan}-> ${green}${fullName}${yellow}... ${end}\c" #
											`unrar x ${file} ${location}/${nameFile// /_} > /dev/null >&1` #
											#Check if everything is ok#
										if [[ -d ${location}/${nameFile// /_} ]]; then #
												echo -e "${green}Sucessful decompression....!${end}"
											else
												echo -e "${red}There was an error unzipping the file, Try Again${end}"
												FAILED
											fi
					  				else
											echo -e "${red}Ocurred Error to Create The Directory${end}"
											FAILED
										fi
									else
										echo -e "${red}Error the ${blue}${nameFile} ${red}directory already exist,${end}" #############
										echo -e "${red}verify the you already have the extracted file${blue}(${red}s${blue})${end}"
										#FAILED
									fi
							fi
					 done
				 fi
			done			
		else
			echo -e "${red}Error Ocurred, The Directory this Empty${end}"
			FAILED
		fi
	else
		echo -e "${red}Error: Input is NOT sopported, Try a Directory${end}"
		FAILED
	fi
}

# MAIN FUNCTION #
if [[ $# -eq 2 ]]; then
	#control of arguments#
	declare -i count=0
	while getopts ":d:f:h:" args; do
			 case $args in
				 	 d ) pathDirectory=$OPTARG; let count+=1;;
					 f ) pathFile=$OPTARG; let count+=1;;
					 h ) HELP_MENU;;
			 esac
	done
	#control of the count value#
	if [[ ${count} -ne 0 ]]; then
		clear; tput civis #Hidde the prompt
	  #starting process the for check the dependences#
		CHECK_DEPENDENCES
		#check if the variable (pathDirectory) is not null#
		if [[ -n ${pathDirectory} ]]; then
			CHECK_DIRECTORY $pathDirectory
		else
		  CHECK_FILE $pathFile
		fi
	  tput cnorm
	else
		HELP_MENU
	fi
else
	HELP_MENU	
fi
