;; sid mouse compatible driver

iirq     = $0314
vic      = $d000
sid      = $d400
potx     = sid+$19
poty     = sid+$1a

vicdata  = $d000         ; copy of vic register image
xpos     = vicdata+$00   ; low order x position
ypos     = vicdata+$01   ; y position
xposmsb  = vicdata+$10   ; bit 0 is high order x position

iirq2    = $c000
opotx    = iirq2+2
opoty    = iirq2+3
newvalue = iirq2+4
oldvalue = iirq2+5

*=$c100
install lda iirq+1
        cmp #>mirq
        beq instend
        php
        sei
        lda iirq
        sta iirq2
        lda iirq+1
        sta iirq2+1

        lda #<mirq
        sta iirq
        lda #>mirq
        sta iirq+1

        plp
instend rts

mirq    cld         ; just in case.....
        lda potx    ; get delta values for x
        ldy opotx
        jsr movchk
        sty opotx

        clc         ; modify low order x position
        adc xpos
        sta xpos
        txa
        adc #$00
        and #%00000001
        eor xposmsb
        sta xposmsb

        lda poty    ; get delta value for y
        ldy opoty
        jsr movchk
        sty opoty
        
        sec         ; modify y position (decrease y for increase in pot)
        eor #$ff
        adc ypos
        sta ypos

        jmp (iirq2) ; continue w/ irq operation

;; movchk
; entryy = old value of pot register
; a      = currrent value of pot register
; exity  = value to use for old value
; x,a    = delta value for position
movchk  sty oldvalue    ; save old & new values
        sta newvalue
        ldx #0          ; preload x w/ 0

        sec             ; a <= mod64 (new - old)
        sbc oldvalue
        and #%01111111
        cmp #%01000000  ; if > 0
        bcs else
        lsr             ; a <= a/2
        beq end         ; if <> 0
        ldy newvalue    ; y <= newvalue
        rts

else    ora #%11000000  ; else or in high order bits
        cmp #$ff        ; if <> -1
        beq end
        sec             ; a <= a/2
        ror a
        ldx #$ff        ; x <= -1
        ldy newvalue    ; y <= newvalue
        rts

end     lda #0          ; a <= 0
        rts             ; return w/ y = old value
