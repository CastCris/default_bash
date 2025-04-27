#!/bin/bash
source $(find -type f -name interpret_line.sh)

relative_path(){ # -init : The point from start | -end : The point from destiny | -dir_start : The path directory where is the point start | -dir_end : The path_direcoty where if the point end
	local standard_values="-init=. -end=home -dir_start=/home/$USER -dir_end=/home/$USER"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))

	local init=${values[0]}
	local end=${values[1]}
	if [[ $init = "." ]];then
		local temp=$(pwd)
		init=${temp##*/}
	fi
	if [[ $end = "." ]];then
		local temp=$(pwd)
		end=${temp##*/}
	fi

	local dir_init=${values[2]}
	local dir_end=${values[3]}

	local path_init="$(find $dir_init -name $init 2>/dev/null)/"
	local path_end="$(find $dir_end -name $end 2>/dev/null)/"

	local path_smallest=${path_init}
	local path_biggest=${path_end}

	if [[ ${#path_smallest} -gt ${#path_biggest} ]];then
		path_smallest=$path_end
		path_biggest=$path_init
	fi

	local path_commum=""
	while [[ ${#path_smallest} -gt 0 ]];do
		if [[ ${path_smallest%%/*} != ${path_biggest%%/*} ]];then
			break
		fi
		path_smallest=${path_smallest#*/}
		path_biggest=${path_biggest#*/}
		path_commum=${path_smallest%%/*}
	done

	local copy_path_init=${path_init%%/}
	local relative_path=""
	while [[ ${copy_path_init##*/} != $path_commum ]];do
		relative_path="$relative_path/.."
		copy_path_init=${copy_path_init%/*}
	done
	#
	local copy_path_end=${path_end%%/}
	local path_end_from_init=""
	while [[ ${copy_path_end##*/} != $path_commum ]];do
		path_end_from_init="${copy_path_end##*/}/$path_end_from_init"
		copy_path_end=${copy_path_end%/*}
	done
	relative_path="$relative_path/$path_end_from_init"

	echo ".$relative_path"
}

relative_path "-init=. -end=/ -dir_start=/home/chincaro/Documents/codes/new_Enigma "
