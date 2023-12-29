This repository contains various C64 assembly program snippets

Contents
---

| Sub-Directory | Contents                                            | Notes             |
|---------------|-----------------------------------------------------|-------------------|
| editor/       | Mr. Ed, simple fullsreen editor by Chris Miller     |                   |
| fileio        | Sample file I/O routines                            |                   |
| georam        | Sample programs for the GeoRAM                      |                   |
| kbd           | Keyboard scan routine by TWW/CTR                    |                   |
| mouse-1351/   | CBM 1351 mouse driver and demo program by Commodore |                   |
| raster-irq/   | Raster interrupt demo                               |                   |
| reu-17xx/     | CBM 17xx REU sample programs                        |                   |
| sprite-joy/   | Joystick controlled sprite demo                     |                   |
| sprite-multi/ | Sprite multiplexer by Lasse Oorni | Requires [pucrunch](https://github.com/r-moeritz/pucrunch) |

Building
---

Run `make` at the top-level to build everything, or `cd` into the
relevant sub-directory and do it there.
