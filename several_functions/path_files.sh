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
get_arch_dir(){ # -path : Path to directory | -type : The type file wish
	local standard_values="-path=. -type=f,d -relative -no_path -no_name -js_path -js_name"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local path=${values[0]}
	local type_file=${values[1]}
	local relative=${values[2]}
	#
	local no_paths=${values[3]}
	local no_names=${values[4]}
	#
	local js_paths=${values[5]}
	local js_names=${values[6]}
	#
	switch_path "-path=$path"

	if [[ $relative = 1 ]];then
		path=""
	else
		path=$(pwd)
	fi

	# EXCLUDE FILES OF SEARCH
	local grep_no_paths=""
	local grep_no_names=""
	for i in $(echo $no_paths | tr "," "\n");do
		if [[ $i = "0" ]] || [[ $i = "" ]];then
			continue
		fi
		grep_no_paths="$grep_no_paths|grep -vw $i"
	done
	for i in $(echo $no_names | tr "," "\n");do
		if [[ $i = "0" ]] || [[ $i = "" ]];then
			continue
		fi
		grep_no_names="$grep_no_names|grep -vw $i"
	done

	# echo "no_names: $grep_no_names"
	# echo "no_paths: $grep_no_paths"
	# JUST FILES IN SEARCH
	local grep_js_names=""
	local grep_js_paths=""

	for i in $(echo $js_names | tr "," "\n");do
		if [[ $i = "0" ]] || [[ $i = "" ]];then
			continue
		fi
		grep_js_names="$grep_js_names|$i"
	done
	if [[ ${#grep_js_names} -ne 0 ]];then
		grep_js_names=${grep_js_names:1}
		grep_js_names="| grep -Ew '$grep_js_names'"
	fi

	for i in $(echo $js_paths | tr "," "\n");do
		if [[ $i = "0" ]] || [[ $i = "" ]];then
			continue
		fi
		grep_js_paths="$grep_js_paths|$i"
	done
	if [[ ${#grep_js_paths} -ne 0 ]];then
		grep_js_paths=${grep_js_paths:1}
		grep_js_paths="| grep -Ew '$grep_js_paths'"
	fi

	# echo "names: $grep_js_names"
	# echo "paths: $grep_js_paths"
	#
	local command_find="find -type $type_file $grep_js_paths $grep_no_paths $grep_js_names $grep_no_names"
	arch="$(eval $command_find)"

	resume_path
	echo "$arch"
}
interpret_arch(){ # -path_file : | -no_tab
	local standard_values="-local -destiny=. -no_tab -relative"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local path_file=${values[0]}
	local destiny=${values[1]}
	local space=${values[2]}
	local relative=${values[3]}
	local i
	local j

	if [ ! -e $path_file ] || [ ! -e $destiny ] || [ -d $path_file ] || [ -f $destiny ];then
		echo "Insert a valid path"
		return
	fi
	
	switch_path "-path=$destiny"
	if [[ $relative = 1 ]];then
		destiny="."
	fi
	local arch="$(cat $path_file | cat -A | sed 's/\^I/@/g')"
	local prev=("$destiny")
	for i in ${arch[@]};do
		i=${i::-1}
		local depth_level=$(echo "$i" | grep -o "@" | wc -l)
		local dir_name=${i##*@}
		local make_var="PATH_${dir_name^^}"

		local path_curr=${prev[0]}
		for j in `seq 1 $depth_level`;do
			path_curr="$path_curr/${prev[$j]}"
		done
		path_curr="$path_curr/$dir_name"

		if [ ! -z "$(eval "echo \$$make_var")" ];then
			local value_make_var=$(eval "echo \$$make_var")
			local new_var="$make_var""_$(dirname ${value_make_var#.} | tr "/" "\n" | cut -c1-2 | sed ':a;N;$!ba;s/\n//g' | tr 'a-z' 'A-Z')=$value_make_var"
			make_var="$make_var""_$(dirname ${path_curr#.} | tr "/" "\n" | cut -c1-2 | sed ':a;N;$!ba;s/\n//g' | tr 'a-z' 'A-Z')"

			eval "$new_var"
			# echo "-$make_var"
			# echo "-$new_var"
		fi
		make_var="$make_var=$path_curr"
		eval "$make_var"
		echo $make_var
		#
		# echo $path_curr
		prev=($(echo $path_curr | tr "/" "\n"))
	done
	resume_path
}
interpret_arch "$@"
