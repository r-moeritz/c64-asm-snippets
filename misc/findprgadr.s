; findprgadr.s
;
; find and print program address
; works by calling into a rom routine, causing the sp to be saved.

*= $c0f7

linprt = $bdcd

findadr         sei                     ; stop irqs from touching the stack
                jsr $f5ae               ; rts
                tsx
                .byte $bd,$ff,$00       ; lda $00ff,x (force abs. x addr.)
                ldy $0100,x             ; high-byte
                cli
fixadr          sec                     ; subtract 3 to fix return address
                sbc #3
                tax                     ; put low-byte in x
                tya                     ; put high-byte in acc.
                sbc #0
printadr        jsr linprt
quit            rts

