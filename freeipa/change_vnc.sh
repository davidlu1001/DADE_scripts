#!/bin/bash

#su ${name_new}

name_ori=$1
name_new=$2

old_pid=`ps aux | grep Xvnc | grep ${name_ori} | grep -v grep | awk '{print $2}'`
kill -9 ${old_pid}
vnc_service=`grep "${name_ori}" /etc/systemd/system/vncserver@\:* | grep -v 'man page' | awk -F':' '{print $1":"$2}' | uniq`
vnc_port=`echo ${vnc_service} | awk -F'[:.]' '{print $2}'`

# 01. copy .vnc
cp /home/${name_ori}/.vnc /home/${name_new} -r
chown ${name_new}:${name_new} /home/${name_new} -R

# 02. modify service
sed -i "s#${name_ori}#${name_new}#g" ${vnc_service}

# 03. check /tmp/.X11-unix
tmp_x11="/tmp/.X11-unix/X${vnc_port}"

# 04. check /tmp/.X[1-5]-lock
tmp_lock="/tmp/.X${vnc_port}-lock"
[[ -e ${tmp_lock} ]] && rm ${tmp_lock}

# 04. reload
systemctl daemon-reload
systemctl restart vncserver@:${vnc_port}

[[ -e ${tmp_x11} ]] && chown ${name_new}:${name_new} ${tmp_x11}
[[ -e ${tmp_lock} ]] && chown ${name_new}:${name_new} ${tmp_lock}
