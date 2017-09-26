BOOTROM_ROOT			?= /home/tifler/work/prj-odysseus/bootrom
LK_ROOT					?= /home/tifler/work/prj-odysseus/lkboot
LK_BOARD_NAME			?= phone-1.0.RM
LK_SYSPLL				?= 1066

KERNEL_ROOT				?= /home/tifler/work/prj-odysseus/kernel
KERNEL_DTB_NAME			?= gdm7243v-refphone1_0

ANDROID_ROOT			?= /home/tifler/work/prj-odysseus/android-7
ANDROID_PRODUCT			?= caterpillar
ANDROID_BUILD_TYPE		?= eng
ANDROID_PRIV_APP_SRC	?= /home/tifler/images/android7.1-gapps-gdm7243v/priv-app

INSTALL_ROOT			?= $(shell pwd)
FW_SRC_DIR				?= /home/tifler/images/latest-fw

WORK_CPUS				?= 6

