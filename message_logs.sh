CONT=0
STOP_FILE="stop"

message(){
	MESSAGE=$1
	STATUS=$2
	TOT_STATUS=$3
	BLOCKS=$4

	PROCENT=$STATUS/$TOT_STATUS
	PORCENT_BLOCKS=$PORCENT*$BLOCKS
		
	CONT=$CONT+1

	while [[ $(find . -type f -name ${STOP_FILE}${CONT}".txt") ]];do
		printf "["${MESSAGE}"]"
		for i in `seq $PORCENT_BLOCKS` 
