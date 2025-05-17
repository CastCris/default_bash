#!/bin/bash
interpret_options(){ # options_curr options_user delimiter 
	local options_curr=($1)
	local options_user=($2)
	local delimiter=$3
	#
	local i
	if [[ ${#delimiter} -eq 0 ]];then
		delimiter="="
	fi

	declare -A options
	local index=0
	while [[ $index -lt ${#options_curr[@]} ]] && [[ $index -lt ${#options_user[@]} ]];do
		local option_syst=${options_curr[$index]%%${delimiter}*}
		local value_syst=${options_curr[$index]#*${delimiter}}
		if [[ $value_syst = $option_syst ]];then
			value_syst="0"
		fi
		if [[ ${#options[$option_syst]} -eq 0 ]];then
			options[$option_syst]=$value_syst
		fi
		#
		local option_user=${options_user[$index]%%${delimiter}*}
		local value_user=${options_user[$index]#*${delimiter}}
		if [[ $value_user = $option_user ]];then
			value_user="1"
		fi
		options[$option_user]=$value_user

		index=$(($index+1))
	done
	while [[ $index -lt ${#options_curr[@]} ]];do
		local options_temp=${options_curr[$index]%%${delimiter}*}
		local value_temp=${options_curr[$index]#*${delimiter}}
		if [[ $value_temp = $options_temp ]];then
			value_temp="0"
		fi
		if [[ ${#options[$options_temp]} -eq 0 ]];then
			options[$options_temp]=$value_temp
		fi

		index=$(($index+1))
	done
	while [[ $index -lt ${#options_user[@]} ]];do
		local options_temp=${options_user[$index]%%${delimiter}*}
		local value_temp=${options_user[$index]#*${delimiter}}
		if [[ $value_temp = $options_temp ]];then
			value_temp="1"
		fi
		options[$options_temp]=$value_temp

		index=$(($index+1))
	done

	for i in ${options_curr[@]};do
		local option_temp=${i%%${delimiter}*}
		echo -n "${options[$option_temp]} "
	done 
}
empty_flag(){ # flag_value default_empty_value
	local flag_value="$1"
	local default_empty_value="$2"
	if [[ $flag_value = $default_empty_value ]];then
		echo ""
		return
	fi
	echo $flag_value
}
