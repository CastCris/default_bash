#!/bin/bash
source $(find . -type f -name import.sh | head -n 1)
import_file "interpret_line.sh"
import_file "message_logs.sh"
import_file "path_files.sh"

# Global variables
PROJECT_NAME="my_project"
PROJECT_PATH="."

# Name directories for main dirs project
DEVELOP_DIR_NAME="develop"
SOURCES_DIR_NAME="sources"
FILE_MAIN_DIR_NAME="is_main"
# for sh aplications
SRC_SH="for_bash"
IMPORT_SH="import_shell"
# for repair the project
REPAIR_DIR="maintenance"

# for programming
SRC_SCRIPT_DIR="src_scripts"
SRC_MODULE_DIR="src_modules"
SRC_OBJECT_DIR="src_objects"
# for C language
C_BUILD_DIR="c_build"
C_COMPILE="gcc"
C_FLAGS="-Wall -Wextra -O2 -std=c99"

# Languages able
ABLE_LANGUAGES=("c")
# Files sh for import
IMPORT_FILES_SH='path_files\.sh|message_logs\.sh|interpret_line\.sh|import\.sh|import_src\.sh'


# Standard attribute for project
STANDARD_OPTIONS=" -name -path -language -develop -sources -is_main -src_sh -import_sh -maintenance -src_s_dir -src_m_dir -src_o_dir"
STANDARD_ARGUMENTS="-name=$PROJECT_NAME -path=$PROJECT_PATH -language=c -develop=$DEVELOP_DIR_NAME -sources=$SOURCES_DIR_NAME -is_main=$FILE_MAIN_DIR_NAME -src_sh=$SRC_SH -import_sh=$IMPORT_SH -maintenance=$REPAIR_DIR -src_s_dir=$SRC_SCRIPT_DIR -src_m_dir=$SRC_MODULE_DIR -src_o_dir=$SRC_OBJECT_DIR -o -path_run=."
: '
-nm: 			name project
-p: 			path for project
-l:				language for project ( only c now...)

-develop: 		rename the develop dir
-sources: 		rename the sources dir
-is_main: 		rename the main file dir

-src_sh: 		rename the source sh dir
-import_sh:		rename the source of import sh dir
-maintenance: 	rename the maintenance sh dir

-src_s_dir		rename the source .c file dir
-src_m_dir 		reamne the source heads files dir
-src_o_dir 		rename the source object from .c files dir 

-o 				unable the output of init_project
'
check_able_language(){ # language
	local language=$1
	for i in ${ABLE_LANGUAGES[@]};do
		if [[ $i = $language ]];then
			echo "1"
			break
		fi
	done
	echo "0"
}
mount_build_files(){ # languages
	local languages=$LANGUAGES
	languages=($(split_str "-str=$languages -del=,"))
	#
	for i in ${languages[@]};do
		if [[ $(check_able_language $i) = 0 ]];then
			continue;
		fi
		local dir_build=""
		local path_build=$PATH_SRC_SH
		if [[ $i = "c" ]];then
			dir_build=$C_BUILD_DIR
			path_build="$path_build/$dir_build"
			mkdir -p $path_build
		fi
		#
		cp $(echo "$(find ./for_init_project -type d -name $dir_build)/*.sh")  $path_build
	done
}
mount_maintenance(){
	cp $(echo "$(find ./for_init_project -type d -name $REPAIR_DIR | head -n 1)/*.sh") $PATH_REPAIR
}
mount_sh_dir(){
	import_file "mksource.sh"
	#
	cp $(find . -type f | grep -P '('$IMPORT_FILES_SH')$') $PATH_IMPORT_SH
	mount_build_files
	mount_maintenance 

	STANDARD_VALUES[1]="."
	mksrc "$(printf "%s " ${STANDARD_VALUES[@]})" "$(printf "%s " ${STANDARD_OPTIONS[@]})"

	mv sources.sh $PATH_SRC_SH
	put_path_src "$PATH_SRC_SH" "$IMPORT_SH|$SRC_SH"
}
main_init_project(){
	PATH_CURR=`pwd`
	cd $PATH_RUN
	#
	PATH_MAIN="./${PROJECT_NAME}"
	PATH_DEVELOP=${PATH_MAIN}/${DEVELOP_DIR_NAME}
	PATH_MAIN_FILE=${PATH_DEVELOP}/${FILE_MAIN_DIR_NAME}

	PATH_SRC_SH=${PATH_DEVELOP}/${SRC_SH}
	PATH_IMPORT_SH=${PATH_SRC_SH}/${IMPORT_SH}
	PATH_REPAIR=${PATH_SRC_SH}/${REPAIR_DIR}
	PATH_SOURCE_FILE=${PATH_SRC_SH}/"sources.sh"
	#
	PATH_SOURCE=${PATH_MAIN}/${SOURCES_DIR_NAME}
	PATH_SCRIPT=${PATH_SOURCE}/${SRC_SCRIPT_DIR}
	PATH_MODULE=${PATH_SOURCE}/${SRC_MODULE_DIR}
	PATH_OBJECT=${PATH_SOURCE}/${SRC_OBJECT_DIR}
	#
	order_to_build=($PATH_MAIN $PATH_DEVELOP $PATH_MAIN_FILE $PATH_SRC_SH $PATH_IMPORT_SH $PATH_REPAIR $PATH_SOURCE $PATH_SCRIPT $PATH_MODULE $PATH_OBJECT)
	for i in ${order_to_build[@]};do
		mkdir -p $i
		echo -e "\e[34m$i\e[0m"
	done
	#
	mount_sh_dir 

	if [[ $PATH_RUN != "." ]];then
		mv $PATH_MAIN $PATH_CURR
		cd $PATH_CURR
	fi
	if [[ $PROJECT_PATH != "." ]];then
		mv $PATH_MAIN $PROJECT_PATH
	fi
}
read_input(){ # user_input
	local user_input="$@"
	STANDARD_VALUES=($(interpret_options "$STANDARD_ARGUMENTS" "$user_input"))
	#
	PROJECT_NAME=${STANDARD_VALUES[0]}
	PROJECT_PATH=${STANDARD_VALUES[1]}
	LANGUAGES=${STANDARD_VALUES[2]}

	DEVELOP_DIR_NAME=${STANDARD_VALUES[3]}
	SOURCES_DIR_NAME=${STANDARD_VALUES[4]}
	FILE_MAIN_DIR_NAME=${STANDARD_VALUES[5]}

	SRC_SH=${STANDARD_VALUES[6]}
	IMPORT_SH=${STANDARD_VALUES[7]}
	REPAIR_DIR=${STANDARD_VALUES[8]}

	SRC_SCRIPT_DIR=${STANDARD_VALUES[9]}
	SRC_MODULE_DIR=${STANDARD_VALUES[10]}
	SRC_OBJECT_DIR=${STANDARD_VALUES[11]}

	OUTPUT=${STANDARD_VALUES[12]}
	PATH_RUN=${STANDARD_VALUES[13]}
}
run(){
	read_input "$@"
	rm -r ${PROJECT_PATH}/${PROJECT_NAME}
	if [[ $OUTPUT = 1 ]];then
		main_init_project > /dev/null
	else
		main_init_project
	fi
}
run "$@"
