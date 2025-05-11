get_path(){
	local path=""
	local path_pwd="`pwd`/"
	path_pwd=${path_pwd:1:${#path_pwd}}
	while [[ ${#path_pwd} -gt 0 ]];do
		if [[ ${path_pwd%%/*} = $PROJECT_NAME ]];then
			echo "$path/$PROJECT_NAME"
			break;
		fi
		path="$path/${path_pwd%%/*}"
		path_pwd=${path_pwd#*/}
	done
}
# global variables for project
PROJECT_NAME=
PROJECT_PATH=

# Languages support by project
LANGUAGES=

# Name of main directories
DEVELOP_DIR=
SOURCES_DIR=
FILE_MAIN_DIR=

# For shell applications
SRC_SH_DIR=
IMPORT_SH_DIR=
REPAIR_DIR=

# For programming
SRC_SCRIPT_DIR=
SRC_MODULE_DIR=
SRC_OBJECT_DIR=

# Path to main directories
PROJECT_PATH=$(get_path)
PATH_MAIN=${PROJECT_PATH}

PATH_DEVELOP=${PATH_MAIN}/${DEVELOP_DIR}
PATH_SRC_SHL=${PATH_DEVELOP}/${SRC_SH_DIR}
PATH_IMPORT_SHL=${PATH_SRC_SHL}/${IMPORT_SH_DIR}
PATH_SOURCE_FILE=${PATH_SRC_SHL}/"sources.sh"
PATH_REPAIR=${PATH_SRC_SHL}/${REPAIR_DIR}
PATH_FILE_MAIN=${PATH_DEVELOP}/${FILE_MAIN_DIR}

PATH_SOURCE=${PATH_MAIN}/${SOURCES_DIR}
PATH_SCRIPT=${PATH_SOURCE}/${SRC_SCRIPT_DIR}
PATH_MODULE=${PATH_SOURCE}/${SRC_MODULE_DIR}
PATH_OBJECT=${PATH_SOURCE}/${SRC_OBJECT_DIR}

