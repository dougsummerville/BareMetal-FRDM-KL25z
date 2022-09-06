#Makefile for bare metal ARM development on Freedom FRDM-KL25Z
#Douglas Summerville, Binghamton University, 2018
CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
OBJSIZE = arm-none-eabi-size
INCLUDES = -Idrivers -Ibaremetal
VPATH = src:drivers:baremetal
SYS_CLOCK = 48000000L
-include config.make

LINKSCRIPT=baremetal/mkl25z4.ld 

OPTS = -O2 "-DSYS_CLOCK=$(SYS_CLOCK)" -DWATCHDOG_DISABLE -DRESET_PIN_DISABLE
TARGET = cortex-m0
CFLAGS = -ffreestanding -nodefaultlibs -nostartfiles \
	 -ffunction-sections -fdata-sections -Wall \
	 -flto -fmessage-length=0 -mcpu=$(TARGET) -mthumb -mfloat-abi=soft \
	 $(DEBUG_OPTS) $(OPTS) $(INCLUDES)
CFLAGSS = -ffreestanding -nodefaultlibs -nostartfiles \
	 -ffunction-sections -fdata-sections -Wall \
	 -fmessage-length=0 -mcpu=$(TARGET) -mthumb -mfloat-abi=soft \
	 $(OPTS) $(INCLUDES)

.PHONY:	clean usage

# -----------------------------------------------------------------------------

usage: 
	$info( To build an application:)
	#@echo "     "LIBS=\"list of drivers\" make file.srec
	#@echo ""


all: $(SREC)
	cp $< /media/$(USER)/DAPLINK/

erase:
	openocd  -f interface/cmsis-dap.cfg -f target/kl25.cfg -c "init" -c "kinetis mdm mass_erase" -c "exit"

clean:
	-rm -f *.o *.elf *.srec  *.dump

_startup.o: _startup.c
	$(CC) $(CFLAGSS) -c $< -o $@
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.dump: %.elf
	$(OBJDUMP) --disassemble $< >$@

%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

#_startup.o must be first in link order- else LTO removes IRQ Handlers
%.elf: _startup.o %.o $(LIBS)
	$(CC) $(CFLAGS) -T $(LINKSCRIPT) -o $@ $^
	#@echo Generated Program has the following segment sizes:
	@$(OBJSIZE) $@

