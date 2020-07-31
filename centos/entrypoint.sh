#!/bin/bash

LUAJIT_DIR=/usr/local/openresty/luajit
ADDONS_DIR=/usr/local/addons
INIT_DIR=/docker-entrypoint-init.d
# 先运行init.d 再运行 addons.rockspec

run_file(){
    echo "found file $1"
	case "$1" in
		*.sh)     echo "[INIT] $0: running $1"; . "$1" ;;
		*)        echo "[INIT] $0: ignoring $1" ;;
	esac
}

run_init(){
    echo "Starting init scripts from '${INIT_DIR}':"
	for fn in $(ls -1 /docker-entrypoint-init.d/* 2> /dev/null)
	do
		# execute script if it didn't execute yet or if it was changed
		cat $INIT_DIR/.cache 2> /dev/null | grep "$(md5sum $fn)" || run_file $fn
	done

	# clear cache
	if [ -e $INIT_DIR/.cache ]; then
		rm $INIT_DIR/.cache
	fi

	# regenerate cache
	ls -1 $INIT_DIR/*.sh 2> /dev/null | xargs md5sum >> $INIT_DIR/.cache

	echo "Init finished"
	echo
}

run_rocks(){
    echo "Starting install rockspec from '${ADDONS_DIR}/addons.rockspec':"

    cat ${ADDONS_DIR}/addons.rockspec.sum 2> /dev/null | grep "$(md5sum ${ADDONS_DIR}/addons.rockspec)"||luarocks install --lua-dir=${LUAJIT_DIR} ${ADDONS_DIR}/addons.rockspec --tree=${ADDONS_DIR}/deps --only-deps --local

    md5sum ${ADDONS_DIR}/addons.rockspec > ${ADDONS_DIR}/addons.rockspec.sum

    echo "Install rockspec finished"
}
run(){
    /usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'
}

run_init
run_rocks
run
