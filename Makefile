# Makefile for SPIScreen - built with the Norcroft/DDE toolchain
# (cc, objasm, cmhg, drlink) via AMU.
#
# Paths below use RISC OS "." directory separators, as is conventional
# for AMU/DDE Makefiles; source files live in the c./h./s./cmhg.
# directories with no filename extension (the RISC OS convention),
# e.g. c.module is the C source for the module/finalisation code,
# h.spiscreen is its header, s.spiasm is the ObjAsm source.
#
# This has not been build-tested against a real DDE install (this repo
# was written in a Linux sandbox with no RISC OS toolchain available) -
# flags in particular are a best effort based on standard Norcroft/ObjAsm
# usage and may need adjusting for your DDE version. Please report back
# any compiler/linker errors so they can be fixed.

CC      = cc
OBJASM  = objasm
CMHG    = cmhg
LD      = link

CFLAGS    = -c -depend !Depend -IC: -throwback -zM
AFLAGS    = -depend !Depend -IC: -throwback -APCS 3/32bit -CloseExec
CMHGFLAGS =

OBJS = o.SPIScreenHdr o.module o.gpio o.lcd o.command

all: SPIScreen

SPIScreen: $(OBJS)
	$(LD) -o SPIScreen -module $(OBJS) C:o.Stubs

o.SPIScreenHdr: cmhg.SPIScreen VersionNum
	$(CMHG) cmhg.SPIScreen -o o.SPIScreenHdr $(CMHGFLAGS)

h.SPIScreenHdr: cmhg.SPIScreen VersionNum
	$(CMHG) cmhg.SPIScreen -d h.SPIScreenHdr $(CMHGFLAGS)

o.module: c.module h.spiscreen h.lcd h.SPIScreenHdr
	$(CC) $(CFLAGS) -o o.module c.module

o.gpio: c.gpio h.spiscreen
	$(CC) $(CFLAGS) -o o.gpio c.gpio

o.lcd: c.lcd h.spiscreen h.lcd h.SPIScreenHdr
	$(CC) $(CFLAGS) -o o.lcd c.lcd

o.command: c.command h.spiscreen h.lcd h.SPIScreenHdr
	$(CC) $(CFLAGS) -o o.command c.command

clean:
	remove o.SPIScreenHdr
	remove o.module
	remove o.gpio
	remove o.lcd
	remove o.command
	remove o.spiasm
	remove SPIScreen

# Dynamic dependencies:
o.module:	c.module
o.module:	C:h.kernel
o.module:	C:h.swis
o.module:	C:Global.h.OSMisc
o.module:	h.SPIDefs
o.module:	h.spiscreen
o.module:	C:h.kernel
o.module:	h.lcd
o.module:	C:h.kernel
o.module:	h.spiscreen
o.module:	h.SPIScreenHdr
o.gpio:	c.gpio
o.gpio:	C:h.kernel
o.gpio:	C:h.swis
o.gpio:	h.spiscreen
o.gpio:	C:h.kernel
o.command:	c.command
o.command:	C:h.kernel
o.command:	C:h.swis
o.command:	h.spiscreen
o.command:	C:h.kernel
o.command:	h.lcd
o.command:	C:h.kernel
o.command:	h.spiscreen
o.command:	h.SPIScreenHdr
o.lcd:	c.lcd
o.lcd:	C:h.kernel
o.lcd:	C:h.swis
o.lcd:	h.SPIDefs
o.lcd:	h.spiscreen
o.lcd:	C:h.kernel
o.lcd:	h.lcd
o.lcd:	C:h.kernel
o.lcd:	h.spiscreen
o.lcd:	h.SPIScreenHdr
o.lcd:	C:Global.h.OSMem
o.lcd:	C:DebugLib.h.DebugLib
