#!/bin/sh

ANDROID_PRIV_APP_SRC=$1
ANDROID_ROOT=$2
TARGET_PRODUCT=$3
OUT_DIR=$4

if [ .$OUT_DIR == . ]; then
    OUT_DIR=out
fi

for app_name in $ANDROID_PRIV_APP_SRC/*
do
    echo "Install app: `basename $app_name`"
    cp -a $app_name $ANDROID_ROOT/$OUT_DIR/target/product/$TARGET_PRODUCT/system/priv-app || exit 1
done
#cp -a $ANDROID_PRIV_APP_SRC/* $ANDROID_ROOT/$OUT_DIR/target/product/$TARGET_PRODUCT/system/ || exit 1

remove_apps_list="
app/DeskClock
app/Calendar
app/ExactCalculator
app/Music
app/WebView
app/Messaging
app/Launcher3
priv-app/Launcher2
";

#for app_name in $remove_apps_list; do
#    echo "Remove app: $app_name"
#	rm -rf $ANDROID_ROOT/$OUT_DIR/target/product/$TARGET_PRODUCT/system/${app_name}
#done;


