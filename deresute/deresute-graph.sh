#!/usr/bin/env bash
# 2019-06-17
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me Image Archiver
# Archive info from game.
# 

# Get script directory, reference https://stackoverflow.com/questions/59895
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path
  # where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

scriptPath="$DIR"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

cd $scriptPath

# Graph, go!
[ ! -d $DATA_PATH ] && mkdir $DATA_PATH
for key in ${!DERESUTE_PROFILE[@]}
do
    ./graph.py "$DATA_PATH/${key}/json" "$PUB_PATH/${DERESUTE_PROFILE[${key}]}" &
done

wait
