# LCDDisplay contributor guide

## What this repository contains

LCDDisplay is a RISC OS module for an ST7789 SPI LCD connected to a Raspberry Pi,
such as the WaveShare 2inch LCD. The module exposes these star commands:

- `*LCDDisplayLoad <sprite file>` loads and displays one 320x240, 16bpp sprite.
- `*LCDDisplayOn` and `*LCDDisplayOff` control the backlight PWM.
- `*LCDDisplayBrightness <brightness>` sets brightness from 0 to 100.
- `*LCDDisplayFade <brightness>` changes brightness in the background using
  `TickerV`.

The implementation is hardware-specific. Changes to register addresses, GPIO
assignments, SPI/DMA setup, panel initialization, or timing should be treated
as hardware changes and reviewed across the related C and header files.

## Repository layout

- `c/module` — module initialization/finalization, peripheral mapping, and
  hardware bring-up.
- `c/lcd` — ST7789 reset/setup, SPI command handling, DMA transfers,
  backlight PWM, and sprite frame uploads.
- `c/command` — star-command dispatch, sprite-file validation, and brightness
  argument parsing.
- `c/fade` — `TickerV`-driven background backlight fades.
- `h/lcddisplay` — shared hardware constants, geometry, channel assignments,
  globals, and declarations.
- `h/lcd`, `h/fade`, and `h/SPIDefs` — component interfaces and peripheral
  register definitions.
- `cmhg/LCDDisplay` — CMHG module metadata, entry points, vector handler, and
  command table.
- `VersionNum` — version values consumed by CMHG.
- `Makefile` — Norcroft/DDE build rules.

Source files intentionally have no filename extensions and use the RISC OS
directory convention (`c.foo`, `h.foo`, `cmhg.foo` in AMU dependency paths).
Build outputs are written under `o/` and the linked module is `LCDDisplay`.

## Build and validation

Build on a RISC OS DDE/Norcroft environment:

```text
amu
```

`amu all` is equivalent. Clean generated outputs with:

```text
amu clean
```

There are no automated tests or lint commands in this repository. The
available validation is a successful AMU build on the target toolchain,
followed by hardware testing on the intended RISC OS/Raspberry Pi setup.
The Makefile has not been validated in this Linux checkout because the
Norcroft tools are not available here.

When changing CMHG declarations, regenerate the generated header as part of
the build; do not hand-edit generated output under `h/` or `o/`.

## Design and implementation rules

- Preserve the singleton hardware model. The module controls one physical
  display and uses global mapped register bases and shared backlight state.
- Keep C-side geometry and buffer assumptions synchronized:
  `SCREEN_WIDTH` is 320, `SCREEN_HEIGHT` is 240, and `SCREEN_DEPTH` is 2
  bytes per pixel.
- `lcd_show_sprite()` expects the first sprite's pixel data at a 44-byte
  offset and byte-swaps each 16-bit pixel before the DMA transfer. Any change
  to sprite layout, mode validation, or byte order must update both the
  loader and display path.
- Use the existing RISC OS SWI APIs (`_swix`, `_swi`, and `_kernel_swi`) and
  platform allocation/mapping mechanisms. Do not introduce POSIX or standard
  desktop I/O as a substitute.
- Preserve explicit error returns. Hardware/SWI failures must propagate as
  `_kernel_oserror *`; do not silently convert failures into successful
  commands.
- Backlight fades claim `TickerV` and must release it on completion,
  cancellation, and module finalization. Direct brightness changes cancel an
  active fade.
- Keep register definitions in `h/SPIDefs` or `h/lcddisplay`, rather than
  duplicating magic addresses in implementation files.
- Keep CMHG command names, handler signatures, and generated symbols aligned
  with `cmhg/LCDDisplay`, `c/command`, and `h/LCDDisplayHdr`.
- Avoid broad refactors in hardware paths. Prefer small, reviewable changes
  with comments only where timing, register semantics, or data layout is not
  self-evident.

## Change workflow

1. Read the relevant C source, header, and CMHG declaration together before
   changing an interface or command.
2. Make the smallest complete change, preserving the existing RISC OS and
   Norcroft conventions.
3. Run `amu` or `amu all` on a RISC OS DDE toolchain when available.
4. For hardware-affecting changes, test reset, panel initialization, sprite
   upload, backlight control, and fade cancellation on the target hardware.
5. Do not commit generated build outputs, local images, archives, or editor
   settings unless the task explicitly requires them.
