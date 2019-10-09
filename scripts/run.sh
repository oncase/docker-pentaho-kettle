#!/bin/bash
ERROR=0

show_info(){
    echo ""
    echo "---------------------------------------------------------------------------"
    echo " PDI_HOME:       " $PDI_HOME
    echo " Add params:     " ${@:3}
    echo "---------------------------------------------------------------------------"
    echo ""
}
show_help(){
  echo ""
  echo "---------------------------------------------------------------------------"
  echo "# Usage:     etl.sh (job|trans) (path-to-file) (extra params)"
  echo "# PDI_HOME: " $PDI_HOME
  echo "---------------------------------------------------------------------------"
  echo ""
  exit 0;
}

if [ "x$1" = "xtrans" ]; then
  EXEC="pan"
elif [ "x$1" = "xjob" ]; then
  EXEC="kitchen"
else
  show_help
fi

if [ -z "$2" ]; then
    show_help
fi

EXECSTR=./$EXEC".sh -file="$2" "${@:3}
echo "Executing "$EXECSTR

show_info
cd $PDI_HOME
echo "Configuring runtime files..."
. ./runtime-config.sh
echo "Runtime files configured..."
echo "Running $1"
. $EXECSTR

exit $ERROR
