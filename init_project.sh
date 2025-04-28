#!/bin/bash
source $(find . -type f -name interpret_line.sh)
source $(find . -type f -name message_logs.sh)
source $(find . -type f -name mksource.sh)

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
	mv $(echo "$(find ./for_init_project -type d -name $REPAIR_DIR)/*.sh") $PATH_REPAIR
}
mount_sh_dir(){
	cp $(find . -type f | grep -P '('$IMPORT_FILES_SH')$') $PATH_IMPORT_SH
	mount_build_files
	mount_maintenance 
	STANDARD_VALUES[1]="-"
	mksrc "${STANDARD_VALUES[@]}"
	mv sources.sh $PATH_SRC_SH
}

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
IMPORT_FILES_SH='path_files\.sh|message_logs\.sh|interpret_line\.sh'
# Standard attribute for project
STANDARD_OPTIONS="-n=$PROJECT_NAME -p=$PROJECT_PATH -l=c -develop=$DEVELOP_DIR_NAME -sources=$SOURCES_DIR_NAME -is_main=$FILE_MAIN_DIR_NAME -src_sh=$SRC_SH -import_sh=$IMPORT_SH -maintenance=$REPAIR_DIR -src_s_dir=$SRC_SCRIPT_DIR -src_m_dir=$SRC_MODULE_DIR -src_o_dir=$SRC_OBJECT_DIR -o"
STANDARD_VALUES=($(interpret_options "$STANDARD_OPTIONS"))
: '
-n: 		name project
-p: 		path for project
-l:			language for project ( only c now...)

-develop: 	rename the develop dir
-sources: 	rename the sources dir
-is_main: 	rename the main file dir

-src_sh: 	rename the source sh dir

-src_c_dir	rename the source .c file dir
-src_h_dir 	reamne the source heads files dir
-src_o_dir 	rename the source object from .c files dir 
'

main_init_project(){
	local user_options="$@"
	STANDARD_VALUES=($(interpret_options "$STANDARD_OPTIONS" "$user_options"))
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

	OUTPUT=${STANDARD_VALUES[$((${#STANDARD_VALUES[@]}-1))]}
	#
	PATH_MAIN=${PROJECT_PATH}/${PROJECT_NAME}
	PATH_DEVELOP=${PATH_MAIN}/${DEVELOP_DIR_NAME}
	PATH_MAIN_FILE=${PATH_DEVELOP}/${FILE_MAIN_DIR_NAME}

	PATH_SRC_SH=${PATH_DEVELOP}/${SRC_SH}
	PATH_IMPORT_SH=${PATH_SRC_SH}/${IMPORT_SH}
	PATH_REPAIR=${PATH_SRC_SH}/${REPAIR_DIR}
	#
	PATH_SOURCE=${PATH_MAIN}/${SOURCES_DIR_NAME}
	PATH_SCRIPT=${PATH_SOURCE}/${SRC_SCRIPT_DIR}
	PATH_MODULE=${PATH_SOURCE}/${SRC_MODULE_DIR}
	PATH_OBJECT=${PATH_SOURCE}/${SRC_OBJECT_DIR}
	#
	order_to_build=($PATH_MAIN $PATH_DEVELOP $PATH_MAIN_FILE $PATH_SRC_SH $PATH_IMPORT_SH $PATH_REPAIR $PATH_SOURCE $PATH_SCRIPT $PATH_MODULE $PATH_OBJECT)
	for i in ${order_to_build[@]};do
		mkdir -p $i
		if [[ $OUTPUT = 0 ]];then
			echo -e "\e[34m$i\e[0m"
		fi
	done
	#
	mount_sh_dir 
}
main_init_project "$@"
