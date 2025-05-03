# mksource.sh

make_src_options(){ # value #options
	local values=($1)
	local options=($2)
	local arguments=""
	for i in ${!options[@]};do
		arguments="$arguments${options[$i]}=${values[$i]} "
	done
	echo $arguments
}
import_files_to_src(){
	echo 'source $(find -type f -name import.sh)' >> sources.sh
	local file_sh_imported=($(echo "$PATH_IMPORT_SH/*.sh"))
	for i in ${file_sh_imported[@]};do
		if [[ ${i##*/} = "import.sh" ]] || [[ ${i##*/} = "import_src.sh" ]];then
			continue;
		fi
		local relative_path_file="source \"$(relative_path "-init=${i%/*} -end=${i##*/} -dir_start=${PATH_SRC_SH} -dir_end=${i%/*}")${i##*/}\""
		echo "$relative_path_file" >> sources.sh
	done  
	echo "">>sources.sh
}

mksrc(){ # values options
	local values=($1)
	local options=($2)

	echo -e '# sources.sh\nSOURCES__IMPORTED__="1"\n' > sources.sh
	import_files_to_src

	local index=0
	while IFS= read -r line;do
		local format_line="$line"
		local temp=${line##*=}

		if [[ ${line##*=} != $line ]] && [[ ${#temp} = 0 ]];then
			format_line="$line\"${values[$index]}\""
			index=$(($index+1))
		fi
		echo "$format_line" >> sources.sh
	done < $(find . -type f -name source_model.sh)

	local arguments="# Options used for construct of project.Don't do anything unless you know what is doing\n $(make_src_options "$(printf "%s " ${values[@]} )" "$(printf "%s " ${options[@]} )")"
	echo -e $arguments > ${PATH_REPAIR}/arguments.txt
	
	echo -e "\e[34m$(cat $(find -type f -name "sources.sh" | head -n 1))\e[0m"
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

		local relative_path_src=$(relative_path "-end=sources.sh -init=${file_sh[0]##*/} -dir_end=$PATH_SRC_SH -dir_start=${file_sh[0]}")
		relative_path_src_temp="${relative_path_src}sources.sh"
		# echo $relative_path_src_temp

		local relative_path_src=""
		for i in `echo $relative_path_src_temp | tr "/" "\n"`;do
			relative_path_src=${relative_path_src}'\/'$i
		done
		relative_path_src=${relative_path_src:2:${#relative_path_src}}
		# echo $relative_path_src
		for j in ${file_sh[@]};do
			sed -i '2s/^/# File signature, dont do anything!\nif [ -z ${SOURCES__IMPORTED__} ];then\n\tPATH_RELATIVE_SH="'${relative_path_src%/*}'"\n\tcd $PATH_RELATIVE_SH\n\tsource "sources.sh"\nfi\n/' $j
		done
	done
}
