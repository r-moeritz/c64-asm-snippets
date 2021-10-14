// cycle border colours

        *= $c000

        lda #$0f
m01:    ldx #$60
m02:    ldy #$ff
m03:    dey
        bne m03
        dex
        bne m02
        sta $d020
        sec
        sbc #$01
        bcs m01
        rts
