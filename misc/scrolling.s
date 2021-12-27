            // Routines for fine scrolling

            *= $c000

                sei
                ldx #$07
                lda $d011
                ora #$07
                sta $d011
L00:            ldy #$06
L01:            jsr MOVPXL
                dex
                bne L01
L02:            lda $d011
                bpl L02
L03:            lda $d011
                bmi L03
L04:            lda #$6B
                cmp $d012
                bne L04
                ldy #$28
L05:            lda $03ff,y
                sta $c076,y
                dey
                bne L05
L06:            lda $0428,y
                sta $0400,y
                iny
                bne L06
L07:            lda $0528,y
                sta $0500,y
                iny
                bne L07
L08:            lda $0628,y
                sta $0600,y
                iny
                bne L08
                ldy #$40
L09:            lda $06e8,y
                sta $06c0,y
                iny
                bne L09
                ldy #$27
L10:            lda $c077,y
                sta $07c0,y
                dey
                bpl L10
                lda $d011
                ora #$07
                sta $d011
                nop
                jmp L00

MOVPXL:         lda $d012
                cmp #$fa
                bne MOVPXL
                dec $d011
                rts
