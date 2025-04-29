import_file(){
	local file=$1
	local new_var="${file%%.*}__IMPORTED__"
	new_var=${new_var^^}

	define='echo $'$new_var''
	if [ -z "`eval $define`" ];then
		eval "$new_var=1"
		echo $(find . -type f -name $file)
		source $(find . -type f -name $file)
	fi
}
