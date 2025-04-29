#!/bin/bash

mksrc(){ # values index
	local values=("$@")
	local index=0
	rm -f sources.sh
	while IFS= read -r line;do
		local format_line="$line"
		local temp=${line##*=}

		if [[ ${line##*=} != $line ]] && [[ ${#temp} = 0 ]];then
			format_line="$line\"${values[$index]}\""
			index=$(($index+1))
		fi
		if [[ $OUTPUT = 0 ]];then
			echo -e "\e[34m$format_line\e[0m"
		fi
		echo "$format_line" >> sources.sh
	done < $(find . -type f -name source_model.sh)
}

put_path_src(){
	local path_src="$1"
	local not_include_dirs="$2"

	local dir_target=($(find $path_src -type d | grep -Pv '/('$not_include_dirs')$'))
	for i in ${dir_target[@]};do
		local file_sh=($(echo "$i/*.sh"))
		if [[ ${file_sh[0]##*/} = "*.sh" ]];then
			continue;
		fi

		local relative_path_temp=$(relative_path "-end=sources.sh -init=${file_sh[0]##*/} -dir_end=$PATH_SRC_SH -dir_start=${file_sh[0]}")
		relative_path_temp="${relative_path_temp}sources.sh"
		echo $relative_path_temp

		local relative_path=""
		for i in `echo $relative_path_temp | tr "/" "\n"`;do
			relative_path=${relative_path}'\/'$i
		done
		relative_path=${relative_path:2:${#relative_path}}
		echo $relative_path
		for j in ${file_sh[@]};do
			sed -i '2s/^/source '$relative_path'\n/' $j
		done
	done
}
