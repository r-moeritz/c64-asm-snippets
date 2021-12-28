                // Kopieren des Bereichs $0000-$0400 in den Rechner-Speicher $400-$7e7 (1 Kb)

                *= $1000

                .const geobuf = $de00
                .const geobuf_sect = $dffe
                .const block = $dfff
                .const membuf = $400    // - $7e7

                lda #$00                // Register auf Block $00 und $0000
                sta geobuf_sect
                sta block
                ldx #$00
                ldy #$00
j1:             lda geobuf,x
j0:             sta membuf,x            // 256 Byte aus GEORam kopieren
                inx
                bne j1
                iny
                sty geobuf_sect
                inc j0+2                // Hi-Byte erhöhen
                cpy #4                  // 4 x 256 = 1 Kb
                bne j1
                sty j0+2                // Speicheradresse restaurieren
                rts
