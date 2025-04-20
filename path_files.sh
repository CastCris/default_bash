#!/bin/bash
relative_path(){
	INIT=$1
	if [[ $INIT = "." ]];then
		TEMP=$(pwd)
		INIT=${TEMP##*/}
	fi
	END=$2

	PATH_COMMUM=""
	PATH_INIT=$(find /home /run -name $INIT 2>/dev/null)
	PATH_END=$(find /home /run -name $END 2>/dev/null)

	INDEX=0
	while [[ $INDEX -lt ${#PATH_INIT} ]] && [[ $INDEX -lt ${#PATH_END} ]] && [[ ${PATH_INIT:$INDEX:1} = ${PATH_END:$INDEX:1} ]];do
		INDEX=$(($INDEX+1))
	done
	for I in $(echo ${PATH_INIT:$INDEX:${#PATH_INIT}} | tr "/" "\n");do
		PATH_COMMUM=${PATH_COMMUM}"../"
	done
	PATH_COMMUM=${PATH_COMMUM}${PATH_END:$INDEX:${#PATH_END}}
	echo $PATH_COMMUM
}
