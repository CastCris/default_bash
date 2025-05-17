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

update_project(){ # -link : | -local : | -import : | -no_import : | -import_path: | -no_import_path : | -delete: | -no_delete: | -delete_path : | -no_delete_path : | -ignore : | -ignore_path : | -just : | -just_path : | -fearless :
	local standard_values="-link=https://github.com/CastCris/default_bash.git -local -import -import_path -no_import -no_import_path -delete -delete_path -no_delete -no_delete_path -ignore -ignore_path -just -just_path -fearless"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))
	#
	local link="${values[0]}"
	local path_db="${values[1]}"
	#
	local import="${values[2]}"
	local import_path="${values[3]}"
	local no_import="${values[4]}"
	local no_import_path="${values[5]}"
	#
	local delete="${values[6]}"
	local delete_path="${values[7]}"
	local no_delete="${values[8]}"
	local no_delete_path="${values[9]}"
	#
	local ignore_names="${values[10]}"
	local ignore_paths="${values[11]}"
	local just_names="${values[12]}"
	local just_paths="${values[13]}"
	#
	local fearless="${values[14]}"
	#
	local i
	#
	import="$import,$just_names"
	import_path="$import_path,$just_paths"
	no_import="$no_import,$ignore_names"
	no_import_path="$no_import_path,$ignore_paths"

	delete="$delete,$just_names"
	delete_path="$delete_path,$just_paths"
	no_delete="$no_delete,$ignore_names"
	no_delete_path="$no_delete_path,$ignore_paths"
	#
	FILE_ARCH_OLD="arch_old"
	FILE_ARCH_NEW="arch_new"
	#
	local arch_old_diff="$(get_arch_dir "-relative -path=$(get_path) -no_name=$no_delete -js_name=$delete -js_path=$delete_path -no_path=$no_delete_path -type=f")"
	local arch_old="$(get_arch_dir "-relative -path=$(get_path) -type=f")"
	if [[ $path_db != "0" ]];then
		update_by_local "$path_db"
	else
		update_by_remote "$link"
	fi
	local arch_new_diff="$(get_arch_dir "-relative -path=./$PROJECT_NAME -no_name=$no_import -js_name=$import -js_path=$import_path -no_path=$no_import_path -type=f")"
	local arch_new="$(get_arch_dir "-relative -path=./$PROJECT_NAME -type=f")"
	#
	echo "$arch_new" > $FILE_ARCH_NEW
	echo "$arch_old" > $FILE_ARCH_OLD
	#
	local diff_new_old="$(comm -2 -3 <(sort $FILE_ARCH_NEW) <(sort $FILE_ARCH_OLD))"
	local diff_old_new="$(comm -2 -3 <(sort $FILE_ARCH_OLD) <(sort $FILE_ARCH_NEW))"

	echo "$arch_new_diff" > $FILE_ARCH_NEW
	echo "$arch_old_diff" > $FILE_ARCH_OLD
	local commum_files="$(comm -12 <(sort $FILE_ARCH_NEW) <(sort $FILE_ARCH_OLD))"
	#
	# cat $FILE_ARCH_OLD
	# cat $FILE_ARCH_NEW
	rm $FILE_ARCH_OLD
	rm $FILE_ARCH_NEW

	# echo -e "NEW X OLD\n$diff_new_old"
	# echo -e "OLD X NEW\n$diff_old_new"

	local path_file=$(get_pwd_path "-path=./$PROJECT_NAME")
	switch_path "-path=$(get_path)"

	arch_new=("$diff_new_old")
	arch_old=("$diff_old_new")
	arch_com=("$commum_files")

	# Import Files
	#
	for i in ${arch_new[@]};do
		local path_single_file="$path_file${i#.}"
		if [[ ! " ${arch_new_diff[@]} " =~ [[:space:]]$i[[:space:]] ]];then
			continue
		fi
		if [[ $fearless = 0 ]];then
			echo -ne "\rImport $i? "
			read -n 1 answer
			#
			echo -ne "\r"
			fill_line_with "-fb=0"
		fi
		if [[ $answer = "n" ]];then
			continue
		fi

		if [ ! -e ${i%/*} ];then
			mkdir -p ${i%/*}
		fi
		cp $path_single_file $i
		echo -e "\e[1;32m Imported\e[0m $i"
	done
	#
	# Delete files
	#
	for i in ${arch_old[@]};do
		if [[ ! " ${arch_old_diff[@]} " =~ [[:space:]]$i[[:space:]] ]] || [ ! -e $i ];then
			continue
		fi
		if [[ $fearless = 0 ]];then
			echo -ne "\rDelete $i? "
			read -n 1 answer
			#
			echo -ne "\r"
			fill_line_with "-fb=0"
		fi
		if [[ $answer = "n" ]];then
			continue
		fi

		rm -r $i
		echo -e "\r\e[1;31m Deleted \e[0m $i"
	done
	#
	# Change files
	#
	for i in ${arch_com[@]};do
		local path_single_file="$path_file${i#.}"
		if [ ! -e $i ] || [[ $(diff_files "-file1=$path_single_file -file2=$i") = "" ]];then
			continue
		fi
		if [[ $fearless = 0 ]];then
			echo -ne "\rChange $i? "
			read -n 1 answer
			#
			echo -ne "\r"
			fill_line_with "-fb=0"
		fi
		if [[ $answer = "n" ]];then
			continue
		fi

		echo "$(cat $path_single_file)" > $i
		echo -e "\r\e[1;33m Changed \e[0m $i"
	done
	fill_line_with "-fb=~"

	resume_path
	rm -r $PROJECT_NAME
}
update_project "$@"
