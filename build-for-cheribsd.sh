#!/bin/sh -e
CHERI_ROOT="${HOME}/cheri"
CHERISDK="${CHERI_ROOT}/output/sdk256/bin"
CHERIBSD_SYSROOT="${CHERI_ROOT}/output/sdk256/sysroot"
INSTALL_DIR=${CHERI_ROOT}/output/rootfs256

# This needs to be done first.  Nginx doesn't support cross-building;
# if you try to tell it to use cheri compiler, it will try to execute
# the output binary and the build will fail.
sh auto/configure --with-debug --without-pcre --without-http_rewrite_module

COMMON_FLAGS="-pipe --sysroot=${CHERIBSD_SYSROOT} -B${CHERISDK} -target cheri-unknown-freebsd -mabi=sandbox -O2 -msoft-float -ggdb -static -integrated-as"
COMPILE_FLAGS="${COMMON_FLAGS} -Wcheri-capability-misuse -Werror=implicit-function-declaration -Werror=format -Werror=undefined-internal"

export CFLAGS=${COMPILE_FLAGS}
export CFLAGS=${COMPILE_FLAGS}
export PATH=${CHERISDK}:${CHERILDDIR}:$PATH
export CC=${CHERISDK}/clang

sed -i '' "s!^CC .*!CC = ${CC}!;s!^CFLAGS .*!CFLAGS = ${CFLAGS}!;s!^CPP .*!CPP = ${CC} -E!;s!^LINK .*!LINK = ${CC} ${CFLAGS}!" objs/Makefile
make
make install DESTDIR=${INSTALL_DIR}
chmod -R a+rX ${INSTALL_DIR}

cp fetchbench ${INSTALL_DIR}/usr/local/nginx/sbin/fetchbench
#chown 0:0 ${INSTALL_DIR}/usr/local/nginx/sbin/fetchbench
chmod 755 ${INSTALL_DIR}/usr/local/nginx/sbin/fetchbench

cp nginx-benchmark.sh ${INSTALL_DIR}/
#chown 0:0 ${INSTALL_DIR}/nginx-benchmark.sh
chmod 755 ${INSTALL_DIR}/nginx-benchmark.sh
