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
diff_files(){ # -file1 : | -file2: 
	local standard_values="-file1 -file2"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local file_receiver=${values[0]}
	local file_issuer=${values[1]}
	echo "$(comm -2 -3 <(sort $file_receiver) <(sort $file_issuer))"
}


diff_archs(){ # -primary : |  -secondary : | -no_files : | -files: | -import | -delete | -type :
	local standard_values="-primary -secondary -no_files -files -import -delete -type=d,f"
	local user_inputs="$@"
	local values=($(interpret_options "$standard_values" "$user_inputs"))

	local primary=${values[0]}
	local secondary=${values[1]}
	local no_files=${values[2]}
	local files=${values[3]}
	local import=${values[4]}
	local delete=${values[5]}
	local type_file=${values[6]}

	if [ ! -e $primary ];then
		echo "The primary dir doesn't exist"
		return
	fi
	if [ ! -e $secondary ];then
		echo "The secondary dir doesn't exist"
		return
	fi
	if [[ $import = 0 ]] && [[ $delete = 0 ]];then
		echo "None operation choose"
		return
	fi

	if [[ $no_files = "1" ]];then
		return
	fi
	#
	local exclude_files=""
	if [[ $no_files != "0" ]];then
		local plus=""
		for i in $(echo "$no_files" | tr "," "\n");do
			exclude_files="$exclude_files $plus -name $i"
			plus="-o"
		done
	fi
	local search_files=()
	# echo $exclude_files
	switch_path "-path=$secondary"
	if [[ $no_files = "0" ]];then
		search_files=("$(find -type $type_file)")
	else
		search_files=("$(find -type $type_file \( $exclude_files \) -prune -o -type $type_file -print)")
	fi
	resume_path
	#
	if [[ $files != "0" ]] && [[ $files != "1" ]];then
		files=("$(echo $files | tr "," "\n")")
	else
		files=("${search_files[@]}")
	fi
	local path_files=$(get_pwd_path "-path=$secondary")

	switch_path "-path=$primary"
	# echo $(pwd)
	# echo $path_files
	# echo "${files[@]}"
	for i in ${files[@]};do
		local path_single_file="$path_files${i#.}"
		if [[ $delete = 1 ]] && [ -e $i ];then
			continue
		elif [[ $delete = 1 ]] && [ ! -e $i ] && [ -e $path_single_file ];then
			echo "$i removed"
			rm -r "$path_single_file"
			continue
		elif [[ $delete = 1 ]];then
			continue
		fi
		#
		if [ -f $i ] && [[ $(diff_files "-file1=$i -file2=$path_single_file") != "" ]];then
			echo "$(cat $path_single_file)" > $i
			echo "$i modified"
		fi
		if [ -e $i ];then
			continue
		fi
		#
		if [ ! -e ${i%/*} ];then
			mkdir -p ${i%/*}
			echo "${i%/*} created"
		fi
		#
		if [ -d $path_single_file ];then
			mkdir -p $i
			echo "$i created"
		else
			cp $path_single_file $i
			echo "$i copied"
		fi 
	done
	resume_path
}

update_project(){ # -link : The link for remote repository reference for update project | -local: Use a reference default_bash dir for update your project | -delete : Delete all files and dir that don't in arch OR delete the select files/dir | -no_import : Not import the missing files of the select arch OR not imported the select files
	local standard_values="-link=https://github.com/CastCris/default_bash.git -local -import -no_import -delete -no_delete"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))
	#

	local link="${values[0]}"
	local path_db="${values[1]}"
	local import="${values[2]}"
	local no_import="${values[3]}"
	local delete="${values[4]}"
	local no_delete="${values[5]}"
	#
	if [[ $path_db != "0" ]];then
		update_by_local "$path_db"
	else
		update_by_remote "$link"
	fi
	diff_archs "-primary=$(get_path) -secondary=./$PROJECT_NAME -import -no_files=sources,$PROJECT_NAME,$no_import -files=$import"
	diff_archs "-secondary=$(get_path) -primary=./$PROJECT_NAME -delete	-no_files=$PROJECT_NAME,sources,$no_delete -files=$delete"

	rm -r $PROJECT_NAME
}
update_project "$@"
