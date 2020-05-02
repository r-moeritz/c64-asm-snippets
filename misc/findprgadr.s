*= $6000

findaddr        jsr $ff40
                tsx
                .byte $bc,$ff,$00 ; ldy $00ff,x (force abs. x addr. mode)
                lda $0100,x ; high byte
                rts

