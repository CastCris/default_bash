#!/bin/bash
interpret_options(){
	options_curr=($1)
	options_user=($2)

	declare -A options
	index=0
	while [[ $index -lt ${#options_curr[@]} ]] && [[ $index -lt ${#options_user[@]} ]];do
		option_syst=${options_curr[$index]%%=*}
		value_syst=${options_curr[$index]##*=}
		if [[ $value_syst = $option_syst ]];then
			value_syst="0"
		fi
		if [[ ${options[$option_syst]} -eq 0 ]];then
			options[$option_syst]=$value_syst
		fi
		#
		option_user=${options_user[$index]%%=*}
		value_user=${options_user[$index]##*=}
		if [[ $value_user = $option_user ]];then
			value_user="1"
		fi
		options[$option_user]=$value_user

		index=$(($index+1))
	done
	while [[ $index -lt ${#options_curr[@]} ]];do
		options_temp=${options_curr[$index]%%=*}
		value_temp=${options_curr[$index]##*=}
		if [[ $value_temp = $options_temp ]];then
			value_temp="0"
		fi
		if [[ ${#options[$options_temp]} -eq 0 ]];then
			options[$options_temp]=$value_temp
		fi

		index=$(($index+1))
	done
	while [[ $index -lt ${#options_user[@]} ]];do
		options_temp=${options_user[$index]%%=*}
		value_temp=${options_user[$index]##*=}
		if [[ $value_temp = $options_temp ]];then
			value_temp="1"
		fi
		options[$options_temp]=$value_temp

		index=$(($index+1))
	done

	echo ${!options[@]}
	echo ${options[@]}
}

interpret_options "-msg=opa\\como\\vai\\baby? -i=10 -b" "-i=5 -msg=sexo\\sonho\\paixao -b -steps=10"
