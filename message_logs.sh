#!/bin/bash

get_stop(){
	echo "stop"$(date +"%s%N")".stop"
}

line(){
	local OPERATIONS=$1
	local TOT_OPERATIONS=$2
	local BLOCKS=$3
	local PORCENT_BLOCKS=$(awk "BEGIN {print $OPERATIONS/$TOT_OPERATIONS*$BLOCKS}")

	local FILL_WITH="="
	local END_WITH=">"

	local OPEN_WITH="["
	local CLOSE_WITH="]"

	printf $OPEN_WITH
	for I in `seq $BLOCKS`;do
		if [[ $I -lt $PORCENT_BLOCKS ]];then
			printf $FILL_WITH
		elif [[ $I = $PORCENT_BLOCKS ]];then
			printf $END_WITH
		else
			printf " "
		fi
	done
	printf $CLOSE_WITH
}
pass_by_message(){ # MESSAGES BLOCKS INDEX STEPS
	local MESSAGE=$1
	local BLOCKS=$2
	local INDEX=$3
	local STEPS=$4

	if [[ $STEPS -lt 0 ]];then
		MESSAGE=$(echo $MESSAGE | rev)
	fi
	local INDEX=$(($INDEX%$BLOCKS))
	
	for I in `seq $BLOCKS`;do
		if [[ $INDEX -lt ${#MESSAGE} ]];then
			echo -n ${MESSAGE:$INDEX:1}
		else
			echo -n " "
		fi
		INDEX=$((($INDEX+$STEPS)%$BLOCKS))

		if [[ $INDEX -lt 0 ]];then
			INDEX=$BLOCKS
		fi
	done
}

pass_multiple_messages(){
	local -n ARRAY_STR=$1
	local INDEX_ITR=$2
	local INDEX_STR=$(($3%${#ARRAY_STR[@]}))

	local BLOCKS=$4
	local DISTANCE=$5

	local TOT_WALKED=0
	local CURR_STR=${ARRAY_STR[0]}
	while [[ $TOT_WALKED -lt $BLOCKS ]];do
		if [[ $INDEX_STR -lt 0 ]];then
			printf " "
			TOT_WALKED=$(($TOT_WALKED+1))
			INDEX_STR=$(($INDEX_STR+1))
		else
			LENGTH=${#CURR_STR}
			if [[ $LENGTH -gt $(($BLOCKS-$LENGTH)) ]];then
				LENGTH=$(($BLOCKS-$LENGTH));
			fi
			pass_by_message $CURR_STR $LENGTH $INDEX_STR 1
			INDEX_ITR=$((($INDEX_ITR+1)%${#ARRAY_STR[*]}))
			#echo -n ${ARRAY_STR[*]}
			INDEX_STR=$((0-$DISTANCE))

			CURR_STR=${ARRAY_STR[$INDEX_ITR]}
			TOT_WALKED=$(($TOT_WALKED+$LENGTH))
		fi
	done
}

TST=("capa" "opa" "epa")
for J in `seq 20`;do
	echo -ne "\r"
	pass_multiple_messages TST 0 J 20 3
	sleep 0.1
done
echo
