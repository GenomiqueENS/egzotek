#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
LID_DIR=/import/rhodos01/shares-net/bin/aozan-ont/lib


# Function to create lib paths
make_paths() {

    local RESULT=
    for lib in `ls $1`
    do
        if [ -f $1/$lib ]; then
            RESULT=$RESULT:$1/$lib
        fi
    done

    echo $RESULT
}

CLASSPATH=$(make_paths $LID_DIR)

java -cp $CLASSPATH --source 11 $SCRIPT_DIR/MergeAnnotation.java $@
