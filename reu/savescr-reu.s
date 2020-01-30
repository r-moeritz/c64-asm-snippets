;; routines for loading and saving the contents of screen memory

*= $c000

.include "reu.s"

baseadr = $0400
xferlen = $0400
savecmd = $90
loadcmd = $91

save    lda #savecmd
        jmp init
load    lda #loadcmd
init    sta args
        ldx #9
loop    lda args,x
        sta command,x
        dex
        bpl loop
        rts

args    .byte 0
        .word baseadr
        .word 0
        .byte 0
        .word xferlen
        .byte 0,0
