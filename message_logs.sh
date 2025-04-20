#!/bin/bash

get_stop(){
	echo "stop"$(date +"%s%N")".stop"
}
get_start(){
	echo "start"$(date +"%s%N")".start"
}

line(){ # OPERATIONS TOT_OPERATIONS BLOCKS 
	local OPERATIONS=$1
	local TOT_OPERATIONS=$2
	local BLOCKS=$3
	local PORCENT_BLOCKS=$(printf %.0f $(awk "BEGIN {print $OPERATIONS/$TOT_OPERATIONS*$BLOCKS}"))

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
pass_by_message(){ # MESSAGE BLOCKS INDEX STEPS
	local MESSAGE=$1
	local BLOCKS=$2
	local INDEX=$3
	local STEPS=$4
	local MAX_INDEX=0

	if [[ $BLOCKS -gt ${#MESSAGE} ]];then
		MAX_INDEX=$BLOCKS
	else
		MAX_INDEX=${#MESSAGE}
	fi

	if [[ $STEPS -lt 0 ]];then
		MESSAGE=$(echo $MESSAGE | rev)
	fi
	local INDEX=$(($INDEX%$MAX_INDEX))
	
	for I in `seq $BLOCKS`;do
		if [[ $INDEX -lt ${#MESSAGE} ]];then
			echo -n ${MESSAGE:$INDEX:1}
			if [[ $(printf "%d" \'${MESSAGE:$INDEX:1}) = 0 ]];then
				echo -n " ";
			fi
		else
			echo -n " "
		fi
		INDEX=$((($INDEX+$STEPS)%$MAX_INDEX))

		if [[ $INDEX -lt 0 ]];then
			INDEX=$BLOCKS
		fi
	done
}
fill_line_with(){ # STR SAMPLE_MESSAGE MESSAGE
	local CHAR=$1
	local SAMPLE_MESSAGE=$2
	local MESSAGE=$3
	local LEN_FILL=$(tput cols)

	if [[ ${#SAMPLE_MESSAGE} -ne 0 ]];then
		LEN_FILL=$((($LEN_FILL-${#SAMPLE_MESSAGE})/2))
	fi
	if [[ ${#MESSAGE} = 0 ]];then
		MESSAGE=$SAMPLE_MESSAGE
	fi
	local INDEX=0
	for i in `seq $LEN_FILL`;do
		echo -n "$CHAR"
		INDEX=$(($INDEX+1))
	done
	if [[ $INDEX = $(tput cols) ]];then
		return
	fi
	echo -ne $MESSAGE
	for I in `seq $LEN_FILL`;do
		echo -n "$CHAR"
	done
	if [[ $((($(tput cols)-${#SAMPLE_MESSAGE})%2)) = 1 ]];then
		echo -n $CHAR
	fi
}
justify_line(){ # SAMPLE_WORDS FILLING WORDS
	SAMPLE_WORDS=$1
	FILLING=$2
	if [[ ${#FILLING} = 0 ]];then
		FILLING=" "
	fi
	WORDS=$3
	if [[ ${#WORDS} = 0 ]];then
		WORDS=$SAMPLE_WORDS
	fi

	ARRAY=()
	AMOUNT_WORDS=0
	LEN_ALL_WORDS=0
	for I in $SAMPLE_WORDS;do
		LEN_ALL_WORDS=$(($LEN_ALL_WORDS+${#I}))
		AMOUNT_WORDS=$(($AMOUNT_WORDS+1))
		ARRAY+=($I)
	done
	if [[ $AMOUNT_WORDS = 1 ]];then
		ARRAY[1]=""
		AMOUNT_WORDS=2
	fi
	LEN_ALL_WORDS=$(($LEN_ALL_WORDS-${#ARRAY[0]}-${#ARRAY[-1]}))
	NUM_SPACE=$(awk "BEGIN {print (($(tput cols)-${#ARRAY[0]}-${#ARRAY[-1]}-1))}")
	NUM_SPACE=$(awk "BEGIN {print ((($NUM_SPACE-$LEN_ALL_WORDS)/($AMOUNT_WORDS-1)))}")
	NUM_SPACE=${NUM_SPACE%%.*}
	SPACES=""
	for I in `seq $NUM_SPACE`;do
		SPACES="${SPACES}$FILLING"
	done
	NEW_ARRAY=()
	for I in $WORDS;do
		NEW_ARRAY+=($I)
	done
	echo -ne ${NEW_ARRAY[0]}
	INDEX=1
	MOMENT=0
	while [[ $INDEX -lt $((${#ARRAY[@]}-1)) ]];do
		if [[ $MOMENT = 0 ]];then # For spaces
			echo -n "$SPACES"
		elif [[ $MOMENT = 1 ]];then # For words
			echo -ne ${NEW_ARRAY[$INDEX]}
			INDEX=$(($INDEX+1))
		fi
		MOMENT=$((($MOMENT+1)%2))
	done 

	REMAIN_SPACE=$(($(tput cols)-$NUM_SPACE*$INDEX-${#ARRAY[-1]}-${#ARRAY[0]}-$LEN_ALL_WORDS))
	if [[ $REMAIN_SPACE -ne 0 ]];then
		for I in `seq $REMAIN_SPACE`;do
			echo -n "$FILLING"
		done
	fi
	echo -ne "$SPACES${NEW_ARRAY[-1]}" 
}
interpret_options(){
	options_str="$1"
	str="$2"

	format_options=()
	for i in $options_str;do
		format_options+=("\\")
	done

	revise=0
	index=0
	for i in $str;do
		revise=$(($revise%2))
		if [[ $revise = 0 ]];then
			for j in $options_str;do
				if [[ "${j}" = "${i}" ]];then
					break;
				fi
				index=$(($index+1))
			done
			revise=$(($revise+1))
			continue
		fi
		#
		format_options[$index]=$i
		index=0
		revise=$(($revise+1))
	done
	echo ${format_options[@]}

}
