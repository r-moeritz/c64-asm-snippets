          ; Mr. Ed by Chris Miller, 1986
          ; Modifications by Ralph Moeritz, 2020-2024
        
          ; *** constants ***
          columns = 40        ; screen size
          linesize = 250      ; max allowed
          screenbeg = $428    ; top of text scr
          screenend = $7e8    ; end of text scr
          rows = 24           ; screenend-screenbeg/columns
          bufferbeg = $0801   ; start of text buffer memory
          bufferend = $7fff   ; end of text buffer memory
          commandnum = 39
        
          ; *** important memory ***
          vic = $d011
          bkg = $d021
          bor = $d020
          rptkey = $28a
          input = $200

          ; *** rom routines ***
          getin = $ffe4
          print = $ffd2
          ready = $e37b
          cnvrtdec = $bdcd

          ; *** variables (zero-page) ***
          vars = $02
          row = $02           ; screen row 0-24
          col = $03           ; screen col 0-39
          shift = $04         ; off screen left
          line = $05          ; text line counter
          cnt = $07           ; display line counter
          num = $08           ; general purpose
          disflg = $09        ; negative=no display
          varnum = 8

          ; *** pointers ***
          ptr = $3d           ; utility pointer
          top = $3f           ; top line of text window
          end = $2d           ; end of text
          txt = $fd           ; current text position
          scr = $fb           ; current screen position

          ; *** beginning of code ***
          *= $c000

start     lda #$80            ; all keys repeat
          sta rptkey

          lda #9
          sta vic             ; screen off

          ldx #11             ; dark grey border
          stx bor
          lda #12             ; light grey background
          sta bkg
          
          jsr message         ; y=0
          
          .byte 144           ; white status line
          .byte 147, 14, 8
          .byte 5             ; black text
          .byte 0

          lda #27             ; screen on
          sta vic

topoftext lda #0
          ldx #varnum - 1     ; init vars

b1        sta vars,x
          dex
          bpl b1

          jsr initialize
          jsr window

          ; main key scan loop
getkey    lda #>getkey        ; always return here
          pha
          lda #<getkey-1
          pha

          jsr reverse
          jsr statusline      ; line, col, mem

b2        jsr getin
          beq b2
          jsr reverse         ; y=0

          ; check command keys
b3        cmp commands,y
          beq foundkey        ; also sets carry
          iny
          iny
          iny
          cpy #commandnum
          bcc b3
          bcs put             ; a typing key

foundkey  lda commands+2,y    ; jump to routine
          pha
          lda commands+1,y
          pha
          rts

          ; put character in text buffer
put       tax                 ; save key
          cmp #13
          beq f1

          ; see if line full
          lda shift
          cmp #linesize-40
          bne f1
          lda col
          cmp #columns-1
          beq r1

f1        jsr testpos         ; are we at end?
          bcc f2

          jsr pshend          ; make room if can
          bcs r1              ; out of memory

f2        cpx #13
          beq cret

          ldy #0
          lda (txt),y
          cmp #13             ; end of a line check
          bne f3
          jsr insert
          
f3        txa
          sta (txt),y
          jsr cnvscr
          sta (scr),y

          ; cursor right routine
right     jsr findeoln
          tya
          beq r1              ; already at end
          inc txt
          bne f4
          inc txt+1
          
f4        lda col
          cmp #columns-1
          bne f5

          inc shift
          jmp window

f5        inc col
          inc scr
          bne r1
          inc scr+1
          
r1        rts

          ; cursor left routine
b4        dec shift           ; scroll left
          jmp window

left      lda col
          ora shift           ; check position
          beq r2              ; cant go left
          jsr dectxt
          lda col
          beq b4
          dec col
          dec scr
          lda scr
          cmp #$ff
          bne f6
          dec scr+1
          
f6        sta scr
r2        rts

          ; carriage return handling routine
cret      jsr findeoln        ; handle carriage return
          txa                 ; x=13
          sta (txt),y

          ; cursor down routine
down      jsr findeoln
          tay
          beq r2              ; already at bottom
          jsr unshift         ; all the way left
          jsr findeoln
          jsr addy
          inc line
          bne f7
          inc line+1
          
f7        lda row
          cmp #rows-1         ; last row check
          bne f8
          jmp topdown         ; scroll down
f8        inc row

addrow    lda scr
          clc
          adc #columns
          bcc f9
          inc scr+1
f9        sta scr
          rts

          ; cursor up routine
up        lda line            ; check position
          ora line+1          ; check position
          beq r3              ; at top already
          dec line
          lda line
          cmp #$ff
          bne f10
          dec line+1
f10       lda txt
          sec
          sbc shift
          bcs f11
          dec txt+1
f11       sta txt
          jsr unshift         ; scroll far left
          ldy #1
          sty num
          dey
b5        jsr dectxt          ; go back 2 cr
          lda (txt),y
          beq f12
          cmp #13
          bne b5
          dec num
          bpl b5

f12       inc txt             ; then forward 1 char
          bne f13
          inc txt+1
f13       lda row             ; top of screen check
          beq topup           ; scroll up

          dec row             ; else move up row
          lda scr
          sec
          sbc #columns
          bcs f14
          dec scr+1
f14       sta scr
r3        rts

          ; move window up
topup     ldy #$ff            ; move text window up line
          dec top+1
b6        dey
          lda (top),y
          beq newtop
          cmp #13
          bne b6

newtop    sec                 ; add y to top pointer
          tya
          adc top
          bcc f15
          inc top+1
f15       sta top
          jmp window

          ; move window down
topdown   ldy #$ff
b7        iny
          lda (top),y
          beq newtop
          cmp #13
          bne b7
          beq newtop

          ; initialize for start of new line
unshift   lda scr
          sec
          sbc col
          bcs f16
          dec scr+1
f16       sta scr
          lda txt
          sec
          sbc col
          bcs f17
          dec txt+1
f17       sta txt
          lda #0
          sta col
          sta shift

          ; move text to screen window
window    bit disflg          ; is display on
          bmi r4              ; no

          lda #rows           ; screenend-screenbeg/columns
          sta cnt

          lda txt+1
          pha                 ; save pointers
          lda txt
          pha
          lda scr+1
          pha
          lda scr
          pha

          lda top
          sta txt             ; init pointers
          lda top+1
          sta txt+1
          jsr initscr

          ; process next line of text
newline   ldy #$ff
b8        jsr testeoln
          beq lineblank
          cpy shift           ; handle right scroll
          bcc b8
          clc
          jsr addy+1          ; update txt ptr
          ldy #$ff
          
b9        jsr testeoln
          beq restblank       ; end of line
          jsr cnvscr          ; convert ascii code
          sta (scr),y         ; put on screen
          cpy #columns-1
          bcc b9

          jsr findeoln+2      ; dont init .y
          jsr addy            ; point next line

addscr    jsr addrow          ; to screen ptr
          dec cnt
          bne newline

fini      pla
          sta scr             ; restore ptrs
          pla
          sta scr+1
          pla
          sta txt
          pla
          sta txt+1
r4        rts

lineblank jsr addy
          ldy #0
          beq f18
restblank jsr addy
f18       lda #' '
b10       sta (scr),y
          iny
          cpy #columns
          bcc b10
          bcs addscr          ; start next line

addy      sec                 ; add y to text ptr
          tya
          adc txt
          bcc f19
          inc txt+1
f19       sta txt
          rts

dectxt    dec txt             ; back up text ptr
          lda txt
          cmp #$ff
          bne f20
          dec txt+1
f20       rts

          ; convert ascii to screen code
cnvscr    eor #128
          bpl f21
          eor #128
          cmp #64
          bcc f21
          eor #64
f21       rts

reverse   pha                 ; reverse cursor char
          ldy #0
          lda (scr),y
          eor #$80
          sta (scr),y
          pla
          rts

testpos   lda txt+1           ; test position in text
          cmp end+1
          bcc f22
          bne f22
          lda txt
          cmp end
f22       rts

insert    lda end+1           ; insert one space
          pha
          lda end
          pha
          ldy #0
b11       lda (end),y
          iny
          sta (end),y
          dey
          dec end
          lda end
          cmp #$ff
          bne f23
          dec end+1
f23       jsr testpos
          bcc b11
          beq b11
          pla
          sta end
          pla
          sta end+1

pshend    lda end+1           ; bump end ptr up
          cmp #>bufferend
          bcc f24
          lda end
          cmp #<bufferend
          bcs r5
f24       inc end
          bne r5
          inc end+1
r5        rts

deletechr lda #1
          sta num
          jsr left
delete    lda txt+1           ; number of chars in num
          pha
          lda txt
          pha
b12       ldy num
          lda (txt),y
          ldy #0
          sta (txt),y
          inc txt
          bne f25
          inc txt+1
f25       jsr testpos
          bcc b12
          beq b12
          pla
          sta txt
          pla
          sta txt+1
          jsr testpos
          bcs f26
          lda end
          sec
          sbc num
          sta end
          bcs f26
          dec end+1
f26       jmp window

insertln  jsr insert          ; insert chr$(13)
          lda #13
          bne f27

insrtspc  jsr insert          ; insert blank
          lda #' '
f27       sta (txt),y
          jmp window

          ; delete line
deleteln  ror disflg          ; display off
          jsr findeoln
          tya
          bne f28
          iny
f28       sty num
          jsr delete
          jmp setwindow

          ; long scroll down
pagedown  ror disflg          ; no display
          ldx #rows-1         ; 23 lines
b13       jsr down
          dex
          bne b13
          beq setwindow

          ; long scroll up
pageup    ror disflg          ; no display
          ldx #rows-1         ; 24 lines
b14       jsr up
          dex
          bne b14
          beq setwindow

pageleft  ror disflg
          ldx #columns-1
b15       jsr left
          dex
          bne b15
          beq setwindow

          ; scroll sideways to end of line
pageright ror disflg          ; no display
          ldx #columns-1
b16       jsr right
          dex
          bne b16
setwindow lsr disflg
          jmp window          ; display

          ; set y=distance to text eol
findeoln  ldy #$ff
b17       jsr testeoln
          bne b17
          rts

testeoln  iny
          cpy #$ff
          beq f29
          lda (txt),y
          beq f29
          cmp #13
f29       rts

initialize lda #<bufferbeg
          ldx #>bufferbeg
          sta end
          stx end+1
f30       sta txt
          sta top
          stx txt+1
          stx top+1
          lda end
          sta ptr
          lda end+1
          sta ptr+1
          ldy #0              ; fill zeros
          tya
b18       sta (ptr),y
          inc ptr
          bne f31
          inc ptr+1
f31       ldx ptr+1
          cpx #>bufferend
          bcc b18
          ldx ptr
          cpx #<bufferend
          bcc b18
initscr   lda #<screenbeg
          sta scr
          lda #>screenbeg
          sta scr+1
          rts

statusline jsr message
          .byte 19            ; (home)
          .text "column:"
          .byte 0
          lda shift
          sec
          adc col
          tax
          tya                 ; =0
          jsr cnvrtdec
          jsr message
          .text " line:"
          .byte 0
          ldy line+1
          ldx line
          inx
          bne f32
          iny
f32       tya
          jsr cnvrtdec
          jsr message
          .text " free:"
          .byte 0
          lda #>bufferend
          sec
          sbc end+1
          tay
          lda #<bufferend
          sbc end
          tax
          tya
          jsr cnvrtdec
          jsr message
          .text "   "         ; 3 spaces
          .byte 0
          rts

          ; print in source messages
message   ldy #0
          pla
          sta ptr
          pla
          sta ptr+1
b19       inc ptr
          bne f33
          inc ptr+1
f33       lda (ptr),y
          beq f34
          jsr print
          bne b19
f34       lda ptr+1
          pha
          lda ptr
          pha
          rts

          ; command entries
commands  .byte 148
          .word insrtspc-1    ; ins     insert space after cursor
          .byte 20
          .word deletechr-1   ; del     delete char before cursor
          .byte 133
          .word deleteln-1    ; f1      delete from cursor to end of line
          .byte 137
          .word insertln-1    ; f2      move text after cursor to next line
          .byte 134
          .word pagedown-1    ; f3      page down
          .byte 138
          .word pageup-1      ; f4      page up
          .byte 135
          .word pageright-1   ; f5      page right
          .byte 139
          .word pageleft-1    ; f6      page left
          .byte 3
          .word ready-1       ; run stop          exit
          .byte 17
          .word down-1        ; (cursor down)
          .byte 145
          .word up-1          ; (cursor up)
          .byte 157
          .word left-1        ; (cursor left)
          .byte 29
          .word right-1       ; (cursor right)
