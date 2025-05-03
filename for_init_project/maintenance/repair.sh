# repair.sh

get_arguments(){
	echo "$(tail -n 1 "$PATH_REPAIR/arguments.txt")"
}
update_by_remote(){ # link | THIS FUNCTION WAS NOT TESTED!!!
	local link="$1"
	local arguments_used="$(get_arguments)"
	#
	echo $arguments_used
	git clone $link
	$(./default_bash/init_project.sh "$arguments_used -path_run=./default_bash/")
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
	local standard_values="-link=https://github.com/CastCris/default_bash.git -local"
	local user_input="$@"
	local values=($(interpret_options "$standard_values" "$user_input"))

	local link="${values[0]}"
	local path_db="${values[1]}"
	if [[ $path_db != "0" ]];then
		update_by_local "$path_db"
	else
		update_by_remote "$link"
	fi
}

update_project "$@"

