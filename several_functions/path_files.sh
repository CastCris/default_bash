#!/bin/bash
source $(find . -type f -name import.sh)
import_file "interpret_line.sh"

switch_path(){ # -path : The relative path for wish directory
	local standard_values="-path=."
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))

	if [ -z $CURR_DIR ];then
		CURR_DIR=$(pwd)
	fi
	local new_path=${values[0]}
	cd $new_path
}
resume_path(){
	if [ -z $CURR_DIR ];then
		return
	fi
	cd $CURR_DIR
	CURR_DIR=""
}
get_pwd_path(){ # -path : The path for wish directory
	local standard_values="-path=."
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local path_wish=${values[0]}
	switch_path "-path=$path_wish"
	local path=$(pwd)
	resume_path
	echo $path
}
relative_path(){ # -init : The point from start | -end : The point from destiny | -dir_start : The path directory where is the point start | -dir_end : The path_direcoty where if the point end
	local standard_values="-init=. -end=home -dir_start=/home/$USER -dir_end=home -search"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))

	local init=${values[0]}
	local end=${values[1]}
	local dir_init=${values[2]}
	local dir_end=${values[3]}
	local search=${values[4]}

	local path_init=""
	local path_end=""
	#
	if [[ $init = "." ]];then
		init=$(pwd)
	fi
	if [[ $end = "." ]];then
		end=$(pwd)
	fi

	if [ -f $init ];then
		init=${init%/*}
	fi
	if [ -f $end ];then
		end=${end%/*}
	fi
	#
	if [[ $search = 1 ]];then
		local path_init="`dirname $(find $dir_init -name ${init##*/} 2>/dev/null)/`"
		local path_end="`dirname $(find $dir_end -name ${end##*/} 2>/dev/null)/`"
	else
		switch_path "-path=$init"
		path_init="$(pwd)"
		resume_path
		#
		switch_path "-path=$end"
		path_end="$(pwd)"
		resume_path
	fi
	# echo "$path_init | $path_end"

	local path_smallest=${path_init}/
	local path_biggest=${path_end}/
	local change=0

	if [[ ${#path_smallest} -gt ${#path_biggest} ]];then
		path_smallest=$path_end
		path_biggest=$path_init
		change=1
	fi

	local dir_commum=""
	local path_commum=""
	while [[ ${#path_smallest} -gt 0 ]];do
		if [[ ${path_smallest%%/*} != ${path_biggest%%/*} ]];then
			break
		fi
		dir_commum=${path_smallest%%/*}
		path_commum="$path_commum/$dir_commum"
		#
		path_smallest=${path_smallest#*/}
		path_biggest=${path_biggest#*/}

	done
	path_commum=${path_commum:1:${#path_commum}}

	local path_back_sml="."
	local path_head_sml=""
	for i in $(echo ${path_smallest} | tr "/" "\n");do
		path_back_sml="$path_back_sml/.."
		path_head_sml="$path_head_sml/$i"
	done
	path_back_sml=${path_back_sml#*/}
	path_head_sml=${path_head_sml%/*}
	path_head_sml=${path_head_sml#/}
	#
	local path_back_big="."
	local path_head_big=""
	for i in $(echo ${path_biggest} | tr "/" "\n");do
		path_back_big="$path_back_big/.."
		path_head_big="$path_head_big/$i"
	done
	path_back_big=${path_back_big#*/}
	path_head_big=${path_head_big%/*}
	path_head_big=${path_head_big#/}
	

	local relative_path=""
	if [[ $change = 0 ]];then
		relative_path="$path_back_sml/$path_head_big"
	else
		relative_path="$path_back_big/$path_head_sml"
	fi
	#
	if [[ ${relative_path:$((${#relative_path}-1)):1} = "/" ]];then
		relative_path=${relative_path%%/}
	fi

	if [[ ${path_end##*/} != ${dir_commum} ]] || [[ $path_end != $path_commum ]];then
		relative_path="$relative_path/${path_end##*/}"
	fi
	echo "$relative_path"
}
get_arch_path(){ # -path : Path to directory | -type : The type file wish
	local standard_values="-path=. -type=f,d -relative"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local path=${values[0]}
	local type_file=${values[1]}
	local relative=${values[2]}
	#
	switch_path "-path=$path"
	if [[ $relative = "0" ]];then
		path=""
	else
		path=$(pwd)
	fi
	local arch="$(find $path -type "$type_file")"	
	
	echo "$arch"
}

