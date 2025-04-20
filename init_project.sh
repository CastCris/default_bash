#!/bin/bash
source $(find . -type f -name message_logs.sh)

OPTIONS_CLI="-n -p -l -develop -sources -is_main -src_sh -src_c_dir -src_h_dir -src_o_dir"
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
# Name directories for main dirs project
DEVELOP_DIR_NAME="develop"
SOURCES_DIR_NAME="sources"
FILE_MAIN_DIR_NAME="is_main"

# for sh aplications
SRC_SH="for_bash"

# for C language
SRC_C_DIR="c_src"
SRC_H_DIR="h_src"
SRC_O_DIR="o_src"


mount_sources_file(){
	content='
#!/bin/bash
# get the path to project
get_main_path(){
	MAIN_DIR=$1
	PATH_MAIN=""
	for i in `pwd | tr "/" "\n"`;do
		PATH_MAIN=${PATH_MAIN}/${i}
		if [[ "$i" == "$MAIN_DIR" ]];then
			break
		fi
	done
	echo $PATH_MAIN
}
# Environment variables for project
PROJECT_NAME="'$1'"
PATH_MAIN=$(get_main_path $PROJECT_NAME)
# Name for main files in project
DEVELOP_DIR_NAME="'$4'"
SOURCES_DIR_NAME="'$5'"
FILE_MAIN_DIR_NAME="'$6'"
# For sh application
SRC_SH="'$7'"

# For c applications
SRC_C_DIR="'$8'"
SRC_H_DIR="'$9'"
SRC_O_DIR="'${10}'"

# Path for main files in project
PATH_DEVELOP=${PATH_MAIN}/${DEVELOP_DIR_NAME}
PATH_FILE_MAIN=${PATH_DEVELOP}/${FILE_MAIN_DIR_NAME}
PATH_SRC_SH=${PATH_DEVELOP}/${SRC_SH}

PATH_SOURCES=${PATH_MAIN}/${SOURCES_DIR_NAME}
PATH_SRC_C=${PATH_SOURCES}/${SRC_C_DIR}
PATH_SRC_H=${PATH_SOURCES}/${SRC_H_DIR}
PATH_SRC_O=${PATH_SOURCES}/${SRC_O_DIR}

# C Flags for compile
C_COMPILE="gcc"
CFLAGS=" -std=99  -Wall -Wextra -O2 "
OUT_FILE_MAIN="application"'
	echo -e "$content" > sources.sh
	mv sources.sh ${2}/${1}/${4}/${7}

}

STANDARD_OPTIONS=("my_project" "." "c" $DEVELOP_DIR_NAME $SOURCES_DIR_NAME $FILE_MAIN_DIR_NAME $SRC_SH $SRC_C_DIR $SRC_H_DIR $SRC_O_DIR)
main_init_project(){
	user_options="$@"
	temp_options=()
	for i in $(interpret_options "$OPTIONS_CLI" "$user_options");do
		temp_options+=($i)
	done
	for i in ${!temp_options[@]};do
		if [[ ${#temp_options[$i]} -ne 1 ]];then
			echo $i ${temp_options[$i]}
			STANDARD_OPTIONS[$i]=${temp_options[$i]}
		fi
	done
	echo ${STANDARD_OPTIONS[@]}
	#
	project_name=${STANDARD_OPTIONS[0]}
	project_path=${STANDARD_OPTIONS[1]}
	language=${STANDARD_OPTIONS[2]}

	DEVELOP_DIR_NAME=${STANDARD_OPTIONS[3]}
	SOURCES_DIR_NAME=${STANDARD_OPTIONS[4]}
	FILE_MAIN_DIR_NAME=${STANDARD_OPTIONS[5]}

	SRC_SH=${STANDARD_OPTIONS[6]}

	SRC_C_DIR=${STANDARD_OPTIONS[7]}
	SRC_H_DIR=${STANDARD_OPTIONS[8]}
	SRC_O_DIR=${STANDARD_OPTIONS[9]}
	#

	dir_main=${project_path}/${project_name}
	dir_develop=${dir_main}/${DEVELOP_DIR_NAME}
	dir_main_file=${dir_develop}/${FILE_MAIN_DIR_NAME}
	dir_src_sh=${dir_develop}/${SRC_SH}
	#
	dir_sources=${dir_main}/${SOURCES_DIR_NAME}
	#
	mkdir -p $dir_main
	echo $dir_main
	mkdir -p $dir_develop
	echo $dir_develop
	mkdir -p $dir_main_file
	echo $dir_main_file
	mkdir -p $dir_src_sh
	echo $dir_src_sh
	#
	mkdir -p $dir_sources
	echo $dir_sources
	for i in `echo $language | tr "," "\n"`;do
		if [[ $i == "c" ]];then
			mkdir -p ${dir_sources}/$SRC_C_DIR
			mkdir -p ${dir_sources}/$SRC_H_DIR
			mkdir -p ${dir_sources}/$SRC_O_DIR
		fi
	done
	#
	mount_sources_file ${STANDARD_OPTIONS[@]}
}
main_init_project "$@"
