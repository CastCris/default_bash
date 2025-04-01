#!/bin/bash

get_stop(){
	echo "stop"$(date +"%s%N")".stop"
}

line(){ # OPERATIONS TOT_OPERATIONS BLOCKS 
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
