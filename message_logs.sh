#!/bin/bash
source $(find . -type f -name interpret_line.sh)

get_stop(){
	echo "stop"$(date +"%s%n")".stop"
}
get_start(){
	echo "start"$(date +"%s%n")".start"
}

line(){ # -o: Operations | -to : Tot operations | -b : Blocks | -fb: Fill blocks | -fs : Fill spaces | -arrow : Arrow for line
	local options="-o=10 -to=100 -b=20 -fb== -fs -arrow=> "
	local user_options="$@"
	local values=($(interpret_options "$options" "$user_options"))

	local operations=${values[0]}
	local tot_operations=${values[1]}
	local blocks=${values[2]}
	local fill_blocks=${values[3]}
	local fill_spaces=${values[4]}
	if [[ $fill_spaces = 0 ]];then
		fill_spaces=" ";
	fi
	local arrow=${values[5]}

	local porcent_blocks=$(printf %.0f $(awk "BEGIN {print $operations/$tot_operations*$blocks}"))

	local open_with="["
	local close_with="]"

	printf $open_with
	for i in `seq $blocks`;do
		if [[ $i -lt $porcent_blocks ]];then
			echo -n $fill_blocks
		elif [[ $i = $porcent_blocks ]];then
			echo -n $arrow
		else
			echo -n "$fill_spaces"
		fi
	done
	echo -n $close_with 
}
split_str(){ # -str : String wish | -del : Delimiter | -rep : Replace the substrings by other substring
	local options='-str=put\\s\where\\yout\\str -del=\\ -rep'
	local user_options="$@"
	local values=($(interpret_options "$options" "$user_options"))

	local str="${values[0]}"
	local del="${values[1]}"
	local rep="${values[2]}"
	if [[ $rep = 0 ]];then
		rep=" "
	fi

	local result=""
	local str_index=-1
	local del_index=0
	local store_str=""
	while [[ $str_index -lt ${#str} ]];do
		str_index=$(($str_index+1))
		if [[ $del_index -eq ${#del} ]];then
			result="${result}${rep}"
			store_str=""
			del_index=0
		fi
		if [[ ${str:$str_index:1} = ${del:$del_index:1} ]];then
			del_index=$(($del_index+1))
			store_str="${store_str}${str:$str_index:1}"
			continue
		fi
		result="${result}${store_str}${str:$str_index:1}"
		store_str=""
		del_index=0
	done
	echo $result
}
pass_by_message(){ # -msg : Message |  -b : Blocks | -i : Index | -steps : Stetps for each iterator | -fs : Fill space | -del : Delimiter for message
	local standard_options='-msg=here\sthe\smessage -b=10 -i=0 -steps=1 -fs -del=\s'
	local user_options="$@"
	local values=($(interpret_options "$standard_options" "$user_options"))

	local message=$(split_str "-str=${values[0]} -del=${values[5]}")
	local blocks=${values[1]}
	local index=${values[2]}
	local steps=${values[3]}
	local fill_space=${values[4]}
	if [[ $fill_sapce = "0" ]];then
		fill_space=" "
	fi
	local max_index=0

	if [[ $blocks -gt ${#message} ]];then
		max_index=$blocks
	else
		max_index=${#message}
	fi

	if [[ $steps -lt 0 ]];then
		message=$(echo $message | rev)
	fi
	local index=$(($index%$max_index))
	
	for i in `seq $blocks`;do
		if [[ $index -lt ${#message} ]];then
			echo -n ${message:$index:1}
			if [[ $(printf "%d" \'${message:$index:1}) = 0 ]];then
				echo -n "$fill_space";
			fi
		else
			echo -n "$fill_space"
		fi
		index=$((($index+$steps)%$max_index))

		if [[ $index -lt 0 ]];then
			index=$blocks
		fi
	done
}
fill_line_with(){ # -fb : Fill block with any character | -smsg: A sample of the message, i.e, without especial characters | -msg : the real message | del : Delimiter for the message
	local options="-fb== -smsg=here^the^message -msg -del=^"
	local user_options="$@"
	local values=($(interpret_options "$options" "$user_options"))

	local char=${values[0]}
	if [[ $char = 0 ]];then
		char=" "
	fi
	local sample_message=$(split_str "-str=${values[1]} -del=${values[3]}")
	local message=${values[2]}
	if [[ $message = 0 ]];then
		message=$sample_message
	else
		message=$(split_str "-str=$message -del=${values[3]}")
	fi


	local len_fill=$(tput cols)
	if [[ ${#sample_message} -ne 0 ]];then
		len_fill=$((($len_fill-${#sample_message})/2))
	fi
	if [[ ${#message} = 0 ]];then
		message=$sample_message
	fi
	local index=0
	for i in `seq $len_fill`;do
		echo -n "$char"
		index=$(($index+1))
	done
	if [[ $index = $(tput cols) ]];then
		return
	fi
	echo -ne $message
	for i in `seq $len_fill`;do
		echo -n "$char"
	done
	if [[ $((($(tput cols)-${#sample_message})%2)) = 1 ]];then
		echo -n $char
	fi 
}
justify_line(){ # -smsg : A message sample | -msg : The real message | -fs : The fill of space | -del : Delimiter of string
	local options="-smsg=here^the^message -msg -fs -del=^"
	local user_options="$@"
	local values=($(interpret_options "$options" "$user_options"))

	sample_words=$(split_str "-str=${values[0]} -del=${values[3]}")
	words=${values[1]}
	if [[ $words = 0 ]];then
		words=$sample_words
	else
		words=$(split_str "-str=$words -del=${values[3]}")
	fi
	filling=${values[2]}
	if [[ $filling = 0 ]];then
		filling=" "
	fi
	
	array=()
	amount_words=0
	len_all_words=0
	for i in $sample_words;do
		len_all_words=$(($len_all_words+${#i}))
		amount_words=$(($amount_words+1))
		array+=($i)
	done
	if [[ $amount_words = 1 ]];then
		array[1]=""
		amount_words=2
	fi
	len_all_words=$(($len_all_words-${#array[0]}-${#array[-1]}))
	num_space=$(awk "BEGIN {print (($(tput cols)-${#array[0]}-${#array[-1]}-1))}")
	num_space=$(awk "BEGIN {print ((($num_space-$len_all_words)/($amount_words-1)))}")
	num_space=${num_space%%.*}
	spaces=""
	for i in `seq $num_space`;do
		spaces="${spaces}$filling"
	done
	new_array=()
	for i in $words;do
		new_array+=($i)
	done
	echo -ne ${new_array[0]}
	index=1
	moment=0
	while [[ $index -lt $((${#array[@]}-1)) ]];do
		if [[ $moment = 0 ]];then # for spaces
			echo -n "$spaces"
		elif [[ $moment = 1 ]];then # for words
			echo -ne ${new_array[$index]}
			index=$(($index+1))
		fi
		moment=$((($moment+1)%2))
	done 

	remain_space=$(($(tput cols)-$num_space*$index-${#array[-1]}-${#array[0]}-$len_all_words))
	if [[ $remain_space -ne 0 ]];then
		for i in `seq $remain_space`;do
			echo -n "$filling"
		done
	fi
	echo -ne "$spaces${new_array[-1]}" 
}

