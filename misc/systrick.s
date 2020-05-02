; systrick.s
;
; find and print program address
; only works if called via basic sys command

*= $6000

linprt = $bdcd

        ldx $14 ; low-byte
        lda $15 ; high-byte
        jsr linprt
        rts

