// routines for loading and saving the contents of screen memory

*= $c000

#import "reu.s"

.const baseadr = $0400
.const xferlen = $0400
.const savecmd = $90
.const loadcmd = $91

save:           lda #savecmd
                jmp init
load:           lda #loadcmd
init:           sta args
                ldx #9
loop:           lda args,x
                sta command,x
                dex
                bpl loop
                rts

args:           .byte 0                 // command
                .word baseadr           // C64 base address
                .word 0                 // REU base address
                .byte 0                 // REU bank
                .word xferlen           // transfer length
                .byte 0,0               // IRQ mask & address control
