                // Kopieren des Bereichs $400-$7e7 in GeoRAM $0000-$0400 (1 Kb)

#import "georam.inc"

                *= $1024

                .const membuf = $400    // - $07e7

                lda #$00                // Register auf Block $00 und $0000
                sta geobuf_sect
                sta block
                ldx #$00
                ldy #$00
j0:             lda membuf,x            // 256 Byte in die GEORam kopieren
                sta geobuf,x
                inx
                bne j0
                iny
                sty geobuf_sect
                inc j0+2                // Hi-Byte erhöhen
                cpy #4                  // 4 x 256 = 1 Kb
                bne j0
                sty j0+2                // Speicheradresse restaurieren
                rts
