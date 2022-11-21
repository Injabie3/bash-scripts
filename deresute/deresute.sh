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

currentDate=`date +"%F_%H-%M-%S"`
scriptPath="$DIR"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

# Full download of images and JSON
[ ! -d $LOCAL_DATA_PATH ] && mkdir $LOCAL_DATA_PATH
for id in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $LOCAL_DATA_PATH/$id ] && mkdir $LOCAL_DATA_PATH/$id
    wget -O "$LOCAL_DATA_PATH/$id/$id-$currentDate.png" https://deresute.me/$id/huge
done

# These downloads will have IDs hidden, and images published on the www
for privateId in ${DERESUTE_PROFILE[@]}
do
    [ ! -d $LOCAL_DATA_PATH/$privateId ] && mkdir $LOCAL_DATA_PATH/$privateId
    wget -O "$LOCAL_DATA_PATH/$privateId/$privateId-$currentDate.png" https://deresute.me/$privateId/huge
    [ ! -d $PUB_PATH ] && mkdir $PUB_PATH
    [ ! -d $PUB_PATH/$privateId ] && mkdir $PUB_PATH/$privateId
    cp "$LOCAL_DATA_PATH/$privateId/$privateId-$currentDate.png" $PUB_PATH/$privateId/banner.png
done

