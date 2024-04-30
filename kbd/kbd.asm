          chrout = $ffd2
          getin = $ffe4
          buf = $200
          zp = $fb
          ysave = $fe
          blnsw = $cc
          blnct = $cd
          blnon = $cf

          *= $c000
          
          ; sample usage:
          ; read line & echo
          ; call from basic via sys49152
;          jsr txtcin          
;strcpt    lda #<buf
;          sta zp
;          ldy #>buf
;          sty zp+1
;          ldy #0
;strlop    lda (zp),y
;          beq finish
;          jsr chrout
;          iny
;          bne strlop
;finish    ldx #$80
;          jmp ($300)          ; return to basic & print ready prompt

          ; read input from keyboard until enter key is pressed
          ; (allow up to 12 characters to be entered)          
          ; and store in buffer at $200, terminate with a 0.
txtcin    .block
          ldy #0
          sty blnsw          
getkey    sty ysave
wait      jsr getin
          ldx #numbad
ckloop    cmp badkey,x
          beq wait
          dex
          bpl ckloop
          ldy ysave
          cmp #20
          bne notdel
          cpy #0
          beq getkey
          dey
          dey
notdel    cmp #13
          beq prtit
          cpy maxlen
          beq getkey
          sta buf,y
          iny
prtit     ldx #1
          stx blnct
waitpr    ldx blnon
          bne waitpr
          sei                 ; disable irqs so cursor won't flash
          
          jsr chrout
          cli                 ; re-enable irqs
          cmp #13
          bne getkey
          lda #0
          sta buf,y
          
          lda #1
          sta blnct
waitbl    lda blnon
          bne waitbl
          lda #1
          sta blnsw
          rts
          
badkey    .byte 0              ; if no key, then wait

          ; up, down, left, right, inst, home, clr
          .byte $91, $11, $9d, $1d, $94, $13, $93 
          
          numbad = * - badkey - 1
          
maxlen    .byte 12            ; max length of input line
          .endblock