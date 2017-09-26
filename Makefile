#------------------------------------------------------------------------------
# Build automation
#
# 20170102	ydlee		Initial draft
#------------------------------------------------------------------------------

ifeq ($(MANUAL_BUILD),)
-include local.mk
endif
include config.mk
include common.mk

#------------------------------------------------------------------------------
# All
#------------------------------------------------------------------------------

PHONY	:=

all:	lk kernel android

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------

PHONY	+= make-target link-latest

make-target:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	mkdir -p $(IMAGE_DST_DIR)

link-latest:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	#rm -rf $(INSTALL_ROOT)/Latest
	#ln -sf $(IMAGE_DST_DIR) $(INSTALL_ROOT)/Latest

#------------------------------------------------------------------------------
# Android
#------------------------------------------------------------------------------

PHONY += android-prepare android-build android-install android-clean \
		 android-sync android-copy-fw android-copy-kernel android-copy-ko \
		 android-copy-priv-app android android-install-gapps android-snod \
		 android-snod-install android-remove-apps

android:	android-prepare android-build android-install link-latest

android-prepare:	android-clean android-sync android-copy-fw android-copy-ko \
	android-copy-kernel android-copy-priv-app

android-clean:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	#cd $(ANDROID_ROOT)/device/anapass/gdm7243v && git reset --hard HEAD

android-sync:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	#cd $(ANDROID_ROOT) && repo sync

android-copy-fw:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	#cp -a $(foreach fw,$(HIFI_BINS),$(FW_SRC_DIR)/$(fw)) $(FW_DST_DIR)
	#cp -a $(FW_SRC_DIR)/tk.bin $(FW_DST_DIR)/tk.bin.fw.0.3.1.0

android-copy-kernel:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	mkdir -p $(IMAGE_SRC_DIR)
	cp $(KERNEL_ROOT)/arch/arm/boot/zImage-dtb $(IMAGE_SRC_DIR)/kernel

android-copy-ko:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	#cp -a $(foreach ko,$(KERNEL_DRIVERS),$(KERNEL_ROOT)/$(ko)) $(MOD_DST_DIR)

android-copy-priv-app:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"

android-build:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	cp -a build-android.sh $(ANDROID_ROOT)
	cd $(ANDROID_ROOT) && ./build-android.sh $(ANDROID_PRODUCT) $(ANDROID_BUILD_TYPE) $(WORK_CPUS)

android-install-gapps:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	./install-priv-app.sh $(ANDROID_PRIV_APP_SRC) $(ANDROID_ROOT) $(ANDROID_PRODUCT) out-$(ANDROID_BUILD_TYPE)

android-remove-apps:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	./remove-app.sh $(ANDROID_ROOT) $(ANDROID_PRODUCT) out-$(ANDROID_BUILD_TYPE)

android-snod:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	cp -a build-android.sh $(ANDROID_ROOT)
	cd $(ANDROID_ROOT) && ./build-android.sh $(ANDROID_PRODUCT) $(ANDROID_BUILD_TYPE) $(WORK_CPUS) snod

#android-install:	make-target android-install-gapps android-remove-apps android-snod
android-install:	make-target
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	cp $(IMAGE_SRC_DIR)/boot.img $(IMAGE_DST_DIR)/
	cp $(IMAGE_SRC_DIR)/recovery.img $(IMAGE_DST_DIR)/
	cp $(IMAGE_SRC_DIR)/system.img $(IMAGE_DST_DIR)/
	cp $(IMAGE_SRC_DIR)/userdata.img $(IMAGE_DST_DIR)/
	cp $(IMAGE_SRC_DIR)/cache.img $(IMAGE_DST_DIR)/

#------------------------------------------------------------------------------
# Kernel
#------------------------------------------------------------------------------

PHONY	+= kernel kernel-build kernel-replace-config kernel-replace-dts

kernel:	kernel-build

kernel-build:	kernel-replace-config kernel-replace-dts
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	@echo "[ Build kernel using "$(KERNEL_DTB_NAME)".dts ]"
	make -C $(KERNEL_ROOT) -j$(WORK_CPUS)

kernel-replace-config:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	@echo "[ Set CONFIG_BUILD_ARM_APPENDED_DTB_IMAGE_NAMES=\"$(KERNEL_DTB_NAME)\" ]"
	sed -e '/CONFIG_BUILD_ARM_APPENDED_DTB_IMAGE_NAMES=/s/=.*/=\"$(KERNEL_DTB_NAME)\"/' \
		$(KERNEL_ROOT)/.config > $(KERNEL_ROOT)/.config.tmp
	mv $(KERNEL_ROOT)/.config.tmp $(KERNEL_ROOT)/.config

kernel-replace-dts:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	@echo "[ Set androidboot.hardware=$(ANDROID_PRODUCT) ]"
	sed -e '/androidboot.hardware=/s/androidboot.hardware=[a-zA-Z0-9]* \(.*\)/androidboot.hardware=$(ANDROID_PRODUCT) \1/' \
		$(KERNEL_ROOT)/arch/arm/boot/dts/$(KERNEL_DTB_NAME).dts > $(KERNEL_ROOT)/.tmp.dts
	mv $(KERNEL_ROOT)/.tmp.dts $(KERNEL_ROOT)/arch/arm/boot/dts/$(KERNEL_DTB_NAME).dts

#------------------------------------------------------------------------------
# LK
#------------------------------------------------------------------------------

PHONY	+= lk lk-build lk-install

lk:	make-target lk-build lk-install

lk-build:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	@echo "[ Build lk for $(LK_TARGET) SYSPLL=$(LK_SYSPLL) ]"
	# Shit. It doesn't work with -j option. Use only single core.
	TARGET_BOARD=$(LK_BOARD_NAME) make -C $(LK_ROOT) -f makefile.gdm7243v SYSPLL=$(LK_SYSPLL) BOOTROM=$(BOOTROM_ROOT)

lk-install:
	cp $(LK_ROOT)/lk.bin $(IMAGE_DST_DIR)/
	cp $(LK_ROOT)/gdmuimg.bin $(IMAGE_DST_DIR)/
	cp $(LK_ROOT)/sbl_*.bin $(IMAGE_DST_DIR)/
	-cp $(LK_ROOT)/iram_S$(SYSPLL)*.bin $(IMAGE_DST_DIR)/
	-cp $(LK_ROOT)/ram_S$(SYSPLL)*.bin $(IMAGE_DST_DIR)/
	cp $(LK_ROOT)/tools/splash/lk_data*.img $(IMAGE_DST_DIR)/
	cp $(LK_ROOT)/odysseus_gpt.bin $(IMAGE_DST_DIR)/

#------------------------------------------------------------------------------
# boot.img
#------------------------------------------------------------------------------

PHONY	+= boot boot-build

boot:	boot-build link-latest

boot-build:	make-target
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	mkbootimg --kernel $(KERNEL_ROOT)/arch/arm/boot/zImage-dtb \
		--ramdisk $(IMAGE_SRC_DIR)/ramdisk.img --base $(KERNEL_LOADADDR) \
		-o $(IMAGE_DST_DIR)/$(BOOT_IMG_TARGET)
	#cp -a $(foreach ko,$(KERNEL_DRIVERS),$(KERNEL_ROOT)/$(ko)) $(IMAGE_DST_DIR)

#------------------------------------------------------------------------------
# recovery.img
#------------------------------------------------------------------------------

PHONY	+= recovery recovery-build

recovery:	recovery-build link-latest

recovery-build:	make-target
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	mkbootimg --kernel $(KERNEL_ROOT)/arch/arm/boot/zImage-dtb \
		--ramdisk $(IMAGE_SRC_DIR)/ramdisk-recovery.img --base $(KERNEL_LOADADDR) \
		-o $(IMAGE_DST_DIR)/$(RECOVERY_IMG_TARGET)

#------------------------------------------------------------------------------
# Test
#------------------------------------------------------------------------------

PHONY	+= test

test:
	@echo "-------------------------------------------------------------------"
	@echo "Stage: $@"
	@echo "-------------------------------------------------------------------"
	echo $(foreach fw,$(HIFI_BINS),$(FW_SRC_DIR)/$(fw))

#------------------------------------------------------------------------------

.PHONY: $(PHONY)
