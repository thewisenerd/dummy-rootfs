# Build initramfs.gz and boot.img
#
# Author: Tom Swindell <t.swindell@rubyx.co.uk>
#
$(warning ********************************************************************************)
$(warning *  You are using the non-android-build approach)
$(warning *  Please don't do this.)
$(warning *  Setup an android build chroot and build your img files there.)
$(warning *  Thank you :D )
$(warning ********************************************************************************)

ifneq ($(MAKECMDGOALS),clean)
DEVICE=$(MAKECMDGOALS)
endif

all:
	$(error Usage: make <device>)

$(DEVICE): setup-$(DEVICE) boot.img-$(DEVICE)

boot.img-$(DEVICE): zImage-$(DEVICE) initramfs.gz-$(DEVICE)
	mkbootimg --kernel ./zImage-$(DEVICE) --ramdisk ./initramfs.gz-$(DEVICE) $(MKBOOTIMG_PARAMS) --output ./boot.img-$(DEVICE)

dt-$(DEVICE):
	$(error Please provide the $(DEVICE) dtb: dt-$(DEVICE))

initramfs.gz-$(DEVICE): initramfs/bin/busybox initramfs/init
	(cd initramfs; chmod +x bin/busybox)
	(cd initramfs; chmod +x bin/sh)
	(cd initramfs; chmod +x init)
	(cd initramfs; find . | cpio -o -H newc -R root:root | gzip -9 > ../initramfs.gz-$(DEVICE))

initramfs/init:
	$(error Missing init script)

initramfs/bin/busybox:
	$(error Please provide the busybox binary)

clean:
	rm -rf ./initramfs.gz-*
	rm -rf ./boot.img-*
	rm -rf ./zImage-*
	rm -rf ./dt-*

setup-pico:
	$(eval KERNEL_BASE	:= 0x12c00000)
	$(eval KERNEL_OFFSET	:= 0x00008000)
	$(eval RAMDISK_OFFSET	:= 0x01000000)
	$(eval TAGS_OFFSET	:= 0x00000100)
	$(eval CMDLINE		:= "console=tty0,115200,n8 fbcon=rotate:1,font:VGA8x16")
	$(eval MKBOOTIMG_PARAMS	:= --cmdline $(CMDLINE) --base $(KERNEL_BASE) --kernel_offset $(KERNEL_OFFSET) --ramdisk_offset $(RAMDISK_OFFSET) --tags_offset $(TAGS_OFFSET))

setup-ferrari: dt-ferrari
	$(eval KERNEL_BASE	:= 0x80000000)
	$(eval KERNEL_OFFSET	:= 0x00008000)
	$(eval RAMDISK_OFFSET	:= 0x01000000)
	$(eval TAGS_OFFSET	:= 0x00000100)
	$(eval CMDLINE		:= "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1")
	$(eval MKBOOTIMG_PARAMS	:= --cmdline $(CMDLINE) --base $(KERNEL_BASE) --kernel_offset $(KERNEL_OFFSET) --ramdisk_offset $(RAMDISK_OFFSET) --tags_offset $(TAGS_OFFSET) --dt ./dt-$(DEVICE))

zImage-pico:
	$(error Please provide the pico zImage)

zImage-ferrari:
	$(error Please provide the ferrari zImage)
