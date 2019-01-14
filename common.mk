BUILD_DATE		:= $(shell date +"%Y%m%d-%H%M%S")

KERNEL_DRIVERS	:= drivers/net/wireless/gdm/gdmwifi.ko drivers/misc/gdm/hifi2_dsp_drv.ko
HIFI_BINS		:= hifi2_code.bin hifi2_data.bin hifi2_sram.bin iram.bin
MOD_DST_DIR		:= $(ANDROID_ROOT)/device/anapass/gdm7243v/proprietary/system/lib/modules
FW_DST_DIR		:= $(ANDROID_ROOT)/device/anapass/gdm7243v/proprietary/system/vendor/firmware
IMAGE_SRC_DIR	:= $(ANDROID_ROOT)/out-$(ANDROID_BUILD_TYPE)/target/product/$(ANDROID_PRODUCT)
IMAGE_DST_DIR	:= $(INSTALL_ROOT)/$(ANDROID_PRODUCT)-$(ANDROID_BUILD_TYPE)

KERNEL_LOADADDR	:= 0x80700000
BOOT_IMG_TARGET	:= boot.$(KERNEL_DTB_NAME).img
RAMDISK_IMG		?= $(IMAGE_SRC_DIR)/ramdisk.img
RECOVERY_RAMDISK_IMG	?= $(IMAGE_SRC_DIR)/ramdisk-recovery.img
RECOVERY_IMG_TARGET		:= recovery.$(KERNEL_DTB_NAME).img
