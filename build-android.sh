#!/bin/sh

DEF_PRODUCT=caterpillar
DEF_MODE=eng

PRODUCT="$1"
MODE="$2"
CPUS="$3"
MAKE_SUBCMD="$4"

if [ .$CPUS == . ]; then
    CPUS=8
fi

case $PRODUCT in
    caterpillar|odysseus|franklin|alexandria|uroad|papagoegg)
        ;;
    *)
        PRODUCT=$DEF_PRODUCT
        ;;
esac

case $MODE in
    user|userdebug|eng)
        ;;
    *)
        MODE=$DEF_MODE
        ;;
esac

case $PRODUCT in
    caterpillar|odysseus|franklin|alexandria)
        LUNCH_NAME=full_$PRODUCT-$MODE
        ;;
    uroad|papagoegg)
        LUNCH_NAME=$PRODUCT-$MODE
        ;;
    *)
        echo "Unknown product:$PRODUCT"
        exit 1
        ;;
esac

export OUT_DIR=out-$MODE
source build/envsetup.sh
lunch $LUNCH_NAME
make -j${CPUS} ${MAKE_SUBCMD}
ret=$?

jack-admin kill-server

exit $ret
