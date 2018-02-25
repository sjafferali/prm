#!/bin/bash

set -u -e

PKG_VERSION="1.1.5"
BUILD_NUMBER="1"
PKG_NAME="prm"
PKG_DESCRIPTION="Process Resource Monitor"
URL="https://github.com/sjafferali/prm"

PREFIX="usr/local/prm"
SBIN_PREFIX="usr/local/sbin"
data_dir=$(cd $(dirname $0) && pwd)
build_dir=$data_dir/build
rm -rf $build_dir
mkdir -p $build_dir/{$PREFIX,$SBIN_PREFIX}
rsync -az files/ $build_dir/$PREFIX/
mkdir $build_dir/$PREFIX/tmp
mkdir $build_dir/$PREFIX/rules
mkdir $build_dir/$PREFIX/logs
cp -a prm $build_dir/$SBIN_PREFIX
cp -a cron.prm $build_dir/prm
cd $build_dir
chmod -R go-w .

fpm --rpm-user root --rpm-group root \
        --description "${PKG_DESCRIPTION}" \
        -a all -s dir -t rpm -v ${PKG_VERSION} -n ${PKG_NAME} \
        --iteration $BUILD_NUMBER --config-files "$PREFIX/conf.prm"  \
        --config-files "$PREFIX/ignore_pslist" --config-files "$PREFIX/ignore_cmd" \
        --config-files "$PREFIX/internals.conf" --config-files "$PREFIX/email.tpl" \
        --config-files "$PREFIX/ignore_users" --config-files "$PREFIX/rules" \
        --config-files "$PREFIX/prios" --url $URL $PREFIX "prm=/etc/cron.d/" "$SBIN_PREFIX"

mv ${PKG_NAME}-* ..
cd ..
rm -rf $build_dir
