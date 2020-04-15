#
# Module Project
#
# (C) 2020.02.02 BuddyZhang1 <buddy.zhang@aliyun.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
ifneq ($(KERNELRELEASE),)

## Target
ifeq ("$(origin MODULE_NAME)", "command line")
MODULE_NAME		:= $(MODULE_NAME)
else
MODULE_NAME		:= BiscuitOS_mod
endif
obj-m			:= $(MODULE_NAME).o

# Architecture Memory
ARCH_MM			:= arm

## Source Code
$(MODULE_NAME)-m	:= main.o
$(MODULE_NAME)-m	+= $(patsubst $(PWD)/%.c,%.o, $(wildcard $(PWD)/mm/*.c))
$(MODULE_NAME)-m	+= $(patsubst $(PWD)/%.c,%.o, $(wildcard $(PWD)/arch/$(ARCH_MM)/*.c)) 

## CFlags
ccflags-y		+= -DCONFIG_NODES_SHIFT=2
# PAGE_OFFSET
ccflags-y		+= -DCONFIG_PAGE_OFFSET_BS=0x90000000
# PHYS_OFFSET
ccflags-y		+= -DCONFIG_PHYS_OFFSET_BS=0x70000000
# CMDLINE
ccflags-y		+= -DCONFIG_CMDLINE_BS="\"mem_bs=0x4000000@0x70000000\""

## Header
ccflags-y		+= -I$(PWD)/arch/$(ARCH_MM)/include
ccflags-y		+= -I$(PWD)/include

else

## Parse argument
## Default support ARM32
ifeq ("$(origin BSROOT)", "command line")
BSROOT=$(BSROOT)
else
BSROOT=/xspace/OpenSource/BiscuitOS/BiscuitOS/output/linux-5.0-arm32
endif

ifeq ("$(origin ARCH)", "command line")
ARCH=$(ARCH)
else
ARCH=arm
endif

ifeq ("$(origin CROSS_TOOLS)", "command line")
CROSS_TOOLS=$(CROSS_TOOLS)
else
CROSS_TOOLS=arm-linux-gnueabi
endif

## Don't Edit
KERNELDIR=$(BSROOT)/linux/linux
CROSS_COMPILE_PATH=$(BSROOT)/$(CROSS_TOOLS)/$(CROSS_TOOLS)/bin
CROSS_COMPILE=$(CROSS_COMPILE_PATH)/$(CROSS_TOOLS)-
INCLUDEDIR=$(KERNELDIR)/include
ARCHINCLUDEDIR=$(KERNELDIR)/arch/$(ARCH)/include
INSTALLDIR=$(BSROOT)/rootfs/rootfs/

## X86/X64 Architecture
ifeq ($(ARCH), i386)
CROSS_COMPILE	:=
else ifeq ($(ARCH), x86_64)
CROSS_COMPILE	:=
endif

## Compile
AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump

# FLAGS
CFLAGS += -I$(INCLUDEDIR) -I$(ARCHINCLUDEDIR)

all: $(OBJS)
	make -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) \
		CROSS_COMPILE=$(CROSS_COMPILE) modules

install:
	make -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) \
		INSTALL_MOD_PATH=$(INSTALLDIR) modules_install
	@chmod 755 RunBiscuitOS_mm.sh
	@cp -rfa RunBiscuitOS_mm.sh $(BSROOT)/rootfs/rootfs/usr/bin

clean:
	@rm -rf *.ko *.o *.mod.o *.mod.c *.symvers *.order \
               .*.o.cmd .tmp_versions *.ko.cmd .*.ko.cmd \
		src/*.o mm/*.o

endif