# Makefile for LCDDisplay - built with the Norcroft/DDE toolchain
# (cc, objasm, cmhg, drlink) via AMU.
#
# Paths below use RISC OS "." directory separators, as is conventional
# for AMU/DDE Makefiles; source files live in the c./h./s./cmhg.
# directories with no filename extension (the RISC OS convention),
# e.g. c.module is the C source for the module/finalisation code,
# h.lcddisplay is its header, s.spiasm is the ObjAsm source.
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

OBJS = o.LCDDisplayHdr o.module o.lcd o.command

all: LCDDisplay

LCDDisplay: $(OBJS)
	$(LD) -o LCDDisplay -module $(OBJS) C:o.Stubs

o.LCDDisplayHdr: cmhg.LCDDisplay VersionNum
	$(CMHG) cmhg.LCDDisplay -o o.LCDDisplayHdr $(CMHGFLAGS)

h.LCDDisplayHdr: cmhg.LCDDisplay VersionNum
	$(CMHG) cmhg.LCDDisplay -d h.LCDDisplayHdr $(CMHGFLAGS)

o.module: c.module h.lcddisplay h.lcd h.LCDDisplayHdr
	$(CC) $(CFLAGS) -o o.module c.module

o.lcd: c.lcd h.lcddisplay h.lcd h.LCDDisplayHdr
	$(CC) $(CFLAGS) -o o.lcd c.lcd

o.command: c.command h.lcddisplay h.lcd h.LCDDisplayHdr
	$(CC) $(CFLAGS) -o o.command c.command

clean:
	remove o.LCDDisplayHdr
	remove o.module
	remove o.gpio
	remove o.lcd
	remove o.command
	remove o.spiasm
	remove LCDDisplay

# Dynamic dependencies:
o.gpio:	c.gpio
o.gpio:	C:h.kernel
o.gpio:	C:h.swis
o.gpio:	h.lcddisplay
o.gpio:	C:h.kernel
o.lcd:	c.lcd
o.lcd:	C:h.kernel
o.lcd:	C:h.swis
o.lcd:	h.SPIDefs
o.lcd:	h.lcddisplay
o.lcd:	C:h.kernel
o.lcd:	h.lcd
o.lcd:	C:h.kernel
o.lcd:	h.lcddisplay
o.lcd:	h.LCDDisplayHdr
o.lcd:	C:Global.h.OSMem
o.lcd:	C:DebugLib.h.DebugLib
o.command:	c.command
o.command:	C:h.kernel
o.command:	C:h.swis
o.command:	h.lcddisplay
o.command:	C:h.kernel
o.command:	h.lcd
o.command:	C:h.kernel
o.command:	h.lcddisplay
o.command:	h.LCDDisplayHdr
o.module:	c.module
o.module:	C:h.kernel
o.module:	C:h.swis
o.module:	C:Global.h.OSMisc
o.module:	h.SPIDefs
o.module:	h.lcddisplay
o.module:	C:h.kernel
o.module:	h.lcd
o.module:	C:h.kernel
o.module:	h.lcddisplay
o.module:	h.LCDDisplayHdr
