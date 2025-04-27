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
OUT_FILE_MAIN="application"
