# repair.sh
get_arguments(){
	echo "$(tail -n 1 "$PATH_REPAIR/arguments.txt")"
}
update_by_remote(){ # link
	local link="$1"
	local arguments_used="$(get_arguments)"
	#
	echo $arguments_used
	git clone $link
	local output="$(./default_bash/init_project.sh "$arguments_used -path_run=./default_bash/" 2>&1)"
	echo "$output"

	rm -r default_bash 
}
update_by_local(){ # path_to_default_bash
	local path_to_db="$1/default_bash"
	local arguments_used="$(get_arguments)"
	#
	local output="$(${path_to_db}/init_project.sh "$arguments_used -path_run=$path_to_db" 2>&1)"
	echo "$output"
}

update_project(){ # -link : The link for remote repository reference for update project | -local: Use a reference default_bash dir for update your project
	local standard_values="-link=https://github.com/CastCris/default_bash.git -local -delete -no_import"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))
	#

	local link="${values[0]}"
	local path_db="${values[1]}"
	local delete="${values[2]}"
	local no_import="${values[3]}"
	if [[ $path_db != "0" ]];then
		update_by_local "$path_db"
	else
		update_by_remote "$link"
	fi
	switch_path "-path=$(get_path)"
	files_to_delete=()
	if [[ $delete != "0" ]] || [[ $delete != "1" ]];then
		files_to_delete=($(echo "$delete" | tr "," "\n"))
	fi
	#
	files_no_import=()
	if [[ $no_import != "0" ]] || [[ $no_import != "1" ]];then
		files_no_import=($(echo "$no_import" | tr "," "\n"))
	fi
	resume_path

	local ignore_path=$(relative_path "-init=$(get_path) -end=./$PROJECT_NAME")
	local path_repair="$(pwd)/$PROJECT_NAME"
	#
	switch_path "-path=$(get_path)"
	local map_project_dir="$(find -path $ignore_path -prune -o -type d -print)"
	local map_project_fls="$(find -path $ignore_path -prune -o -type f -print)"
	resume_path
	#
	switch_path "-path=$PROJECT_NAME"
	local map_repair_dir="$(find -type d)"
	local map_repair_fls="$(find -type f)"
	: '
	echo "${map_project_dir[@]}"
	echo "${map_project_fls[@]}"
	#
	echo "----"
	#
	echo "${map_repair_dir[@]}"
	echo "${map_repair_fls[@]}"
	'
	switch_path "-path=$(get_path)"

	# Directories
	for i in ${map_repair_dir[@]};do
		if [[ " ${map_project_dir[@]} " =~ [[:space:]]${i}[[:space:]] ]] || [[ $no_import = 1 ]];then
			continue
		fi
		if [[ $no_import != "0" ]] && [[ " ${files_no_import[@]} " =~ [[:space:]]${i##*/}[[:space:]] ]];then
			continue
		fi
		mkdir -p $i
		echo "dir ${i##*/} imported"
	done
	#
	for i in ${map_project_dir[@]};do
		if [[ " ${map_repair_dir[@]} " =~ [[:space:]]${i}[[:space:]] ]] || [[ $delete = 0 ]] || [ ! -e $i ];then
			continue
		fi
		if [[ $delete != "1" ]] && [[ ! " ${files_to_delete[@]} " =~ [[:space:]]${i##*/}[[:space:]] ]];then
			continue
		fi
		echo "dir ${i##*/} removed"
		rm -r $i
	done
	# Files
	for i in ${map_repair_fls[@]};do
		if [[ " ${map_project_fls[@]} " =~ [[:space:]]${i}[[:space:]] ]] || [[ $no_import = 1 ]];then
			continue
		fi
		if [[ $no_import != "0" ]] && [[ " ${files_no_import[@]} " =~ [[:space:]]${i##*/}[[:space:]] ]];then
			continue
		fi
		cp "${path_repair}${i#.}" ${i%/*}
		echo "file ${i##*/} imported"
	done
	#
	for i in ${map_project_fls[@]};do
		if [[ " ${map_repair_fls[@]} " =~ [[:space:]]${i}[[:space:]] ]] || [[ $delete = 0 ]] || [ ! -e $i ];then
			continue
		fi
		if [[ $delete != "1" ]] && [[ ! " ${files_to_delete[@]} " =~ [[:space:]]${i##*/}[[:space:]] ]];then
			continue
		fi
		echo "file ${i##*/} removed"
		rm $i
	done

	resume_path 
	rm -r $PROJECT_NAME
}
