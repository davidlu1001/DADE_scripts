#!/bin/bash

MONITOR="/localdata"
EVENT="modify,attrib,close_write,move,create"
LOG_SCAN="/var/log/clamd.scan"
LOGFILE="/var/log/inotify.log"

proc_num=$(ps -ef | grep "inotify" | grep -vw $$ | grep -vw "grep" | wc -l)
if [[ $proc_num -ne 0 ]]
then
#   echo -e "Already running, exit.\n"
   exit
fi
#/usr/bin/inotifywait --format '%T %:e %w%f' --timefmt '%Y-%m-%d %H:%M:%S' -e $EVENT -o $LOGFILE -dmrq $MONITOR |
/usr/bin/inotifywait --format '%T %:e %w%f' --timefmt '%Y-%m-%d %H:%M:%S' -e $EVENT -mrq $MONITOR | tee -a $LOGFILE |
while read file
do
    INO_DIR=$(dirname `echo $file | awk '{print $4}'`)
    INO_FILE=$(echo $file | awk '{print $4}')
    /usr/bin/clamscan $INO_FILE -l $LOG_SCAN --quiet > /dev/null 2>&1
done
