#!/bin/bash
mksrc(){
	local values=("$@")
	local index=0
	rm -f sources.sh
	while read line;do
		local format_line=$line
		local temp=${line##*=}

		if [[ ${line##*=} != $line ]] && [[ ${#temp} = 0 ]];then
			format_line=${line}${values[$index]}
			index=$(($index+1))
		fi
		if [[ $OUTPUT = 0 ]];then
			echo -e "\e[34m$format_line\e[0m"
		fi
		echo $format_line >> sources.sh
	done < $(find . -type f -name source_model.sh)
}
