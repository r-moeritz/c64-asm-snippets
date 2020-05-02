; findprgadr.s
;
; find and print program address
; works by calling into a rom routine, causing the sp to be saved.

*= $6000

linprt = $bdcd

findadr         jsr $f5ae ; rts
                tsx
                .byte $bd,$ff,$00 ; lda $00ff,x (force abs. x addr. mode)
                ldy $0100,x ; high byte
printadr        tax ; store low-byte in x
                tya ; store high-byte in a
                jsr linprt
quit            rts

