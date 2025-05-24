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

format_log_file_inter_arch(){ # log_file: | sort_by: 
	local log_file="$1"
	local sort_by="$2"
	local i
	if [[ $log_file = "0" ]];then
		return
	fi
	#
	while read -r line;do
		local var_name="${line%=*}"
		local var_cont=="${line#*=}"
		local var_amount=$(grep -wo $var_name $log_file | wc -l)
		if [[ $var_amount -lt 2 ]];then
			continue
		fi
		local vars_content=($(grep -w $var_name $log_file | sed -n 's/.*=//p'))
		local vars_content_rev=()
		for i in ${vars_content[@]};do
			vars_content_rev+=($(echo $i | tr '/' '\n' | tac | tr '\n' '/'| cut -d'/' -f3-))
		done
		# echo "****"
		# echo "vars_content=${vars_content_rev[@]}"
		local index=1
		local treated_names=()
		while [[ ${#treated_names[@]} -lt ${#vars_content[@]} ]];do
			local dirs_names=($(echo ${vars_content_rev[@]} | tr ' ' '\n' | cut -d'/' -f1-$index))
			# echo "dirs_names=${dirs_names[@]}"
			for i in ${!dirs_names[@]};do
				local curr_item_rev=${vars_content_rev[$i]}
				local curr_item=${vars_content[$i]}
				 # echo "rev:$curr_item_rev"
				if [[ $curr_item_rev = "./" ]];then
					treated_names+=("./")
					continue
				fi
				if [[ $(echo "${dirs_names[@]}" | grep -o ${dirs_names[$i]} | wc -l) -gt 1 ]] || [[ " ${treated_names[@]} " =~ [[:space:]]$curr_item_rev[[:space:]] ]];then
					continue
				fi
				local new_var_name="${var_name}__$(echo $curr_item_rev | cut -d'/' -f-$index | tr '/' '_' | tr '[:lower:]' '[:upper:]')"
				local new_var="${new_var_name}=$curr_item"
				# echo "$new_var"
				sed -i 's|.*'$curr_item'$|'$new_var'|' $log_file
				# echo "======"
				treated_names+=($curr_item_rev)
			done
			index=$(($index+1))
			# echo "treated_names=${treated_names[@]}"
		done
	done < $log_file
	if [[ $sort_by = "name" ]];then
		echo "$(cat $log_file | sort )" > $log_file
	elif [[ $sort_by = "path" ]];then
		echo "$(cat $log_file | sort -t= -k2 )" > $log_file
	fi
	local biggest_len_word=0
	for i in $(cat $log_file);do
		local word=${i%=*}
		if [[ ${#word} -gt $biggest_len_word ]];then
			biggest_len_word=${#word}
		fi
	done
	echo "$(awk -F= '{ printf "%-'$biggest_len_word's = %s\n", $1, $2}' $log_file)" > $log_file
}
interpret_arch(){
	local standard_values="-local -destiny=. -no_tab -relative -make -log -sort"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local path_file=${values[0]}
	local destiny=${values[1]}
	local space=${values[2]}
	local relative=${values[3]}
	local make=${values[4]}
	local log=${values[5]}
	local sort_log=${values[6]}
	local i
	local j
	if [[ $log = 1 ]];then
		log="interpret_arch.txt"
	fi
	if [[ $sort_log = 1 ]];then
		sort_log="path"
	fi

	if [ ! -e $path_file ] || [ ! -e $destiny ] || [ -d $path_file ] || [ -f $destiny ];then
		echo "Insert a valid path"
		return
	fi
	
	local arch="$(cat $path_file | cat -A | sed 's/\^I/@/g')"
	switch_path "-path=$destiny"
	if [ -e $log ];then
		rm $log
	fi
	touch $log
	if [[ $relative = 1 ]];then
		destiny="."
	fi
	local prev=("$destiny")
	local paths_useds=()
	for i in ${arch[@]};do
		i=${i::-1}
		local dir_name=${i##*@}
		local var_name="PATH_${dir_name^^}"
		local del_cont=$(echo "$i" | grep -o "@" | wc -l)

		local dir_path=${prev[0]}
		for j in `seq 1 $del_cont`;do
			dir_path="$dir_path/${prev[$j]}"
		done
		dir_path="$dir_path/$dir_name"
		prev=($(echo $dir_path | tr "/" "\n"))

		if [[ " ${paths_used[@]} " =~ [[:space:]]$dir_path[[:space:]] ]];then
			continue
		fi
		# echo "$var_name=$dir_path"
		paths_used+=(${dir_path})
		#
		if [[ $log != "0" ]];then
			echo "$var_name=$dir_path/" >> $log
		fi
		if [[ $make != "0" ]];then
			mkdir -p $dir_path
		fi
	done
	format_log_file_inter_arch "$log" "$sort_log"
	#
	resume_path
}
interpret_arch "$@"
