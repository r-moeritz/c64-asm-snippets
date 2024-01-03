          ; Mr. Ed by Chris Miller, 1986
          ; Modifications by Ralph Moeritz, 2020-2024
        
          ; *** constants ***
          columns = 40        ; screen size
          linesize = 80       ; max allowed chars/line
          screenbeg = $428    ; top of text scr
          screenend = $7e8    ; end of text scr
          rows = 24           ; screenend-screenbeg/columns
          bufferbeg = $0801   ; start of text buffer memory
          bufferend = $7fff   ; end of text buffer memory
          commandnum = 42     ; size of commands table
        
          ; *** important memory ***
          vic = $d011
          bkg = $d021
          bor = $d020
          rptkey = $28a
          input = $200
          status = $90    
          blnsw = $cc
          blnct = $cd
          blnon = $cf              

          ; *** rom routines ***
          getin = $ffe4
          ready = $e37b
          cnvrtdec = $bdcd
          setlfs = $ffba
          setnam = $ffbd
          open = $ffc0
          chkin = $ffc6
          chkout = $ffc9
          chrin = $ffcf
          chrout = $ffd2
          close = $ffc3
          clrchn = $ffcc                             

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
          nostatus = $50      ; disable status line update, 1=yes, 0=no
          ysave = $51      

          ; *** pointers ***
          end = $2d           ; end of text
          ptr = $3d           ; utility pointer
          top = $3f           ; top line of text window          
          scr = $fb           ; current screen position
          txt = $fd           ; current text position          
          bufptr = $4c        ; pointer to text buffer
          fnmptr = $4e        ; pointer to zero-terminated filename                 

          ; *** beginning of code ***
          *= $c000

          ; program entry
start     lda #$80            ; all keys repeat
          sta rptkey         

          lda #9
          sta vic             ; screen off

          ldx #11             ; dark grey border
          stx bor
          lda #12             ; light grey background
          sta bkg
          
          lda #0
          sta nostatus        ; enable status line
          
          jsr message         ; y=0
          
          .byte 144           ; white status line
          .byte 147, 14, 8
          .byte 5             ; black text
          .byte 0

          lda #27             ; screen on
          sta vic

topoftext .block
          lda #0
          ldx #varnum - 1     ; init vars

b1        sta vars,x
          dex
          bpl b1

          jsr initialize
          jsr window
          .endblock

          ; main key scan loop
getkey    .block
          lda #>getkey        ; always return here
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
          .endblock

          ; put character in text buffer
put       .block
          tax                 ; save key
          cmp #13
          beq f1

          ; see if line full
          lda shift
          cmp #linesize-40
          bne f1
          lda col
          cmp #columns-1
          beq right.r1
          
f1        jsr testpos         ; are we at end?
          bcc f2

          jsr pshend          ; make room if can
          bcs right.r1        ; out of memory

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
          .endblock

          ; cursor right routine
right     .block
          jsr findeoln
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
          .endblock

          ; cursor left routine
left      .block
          lda col
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

b4        dec shift           ; scroll left
          jmp window
          .endblock
          
          ; carriage return handling routine
cret      jsr findeoln        ; handle carriage return
          txa                 ; x=13
          sta (txt),y

          ; cursor down routine
down      .block
          jsr findeoln
          tay
          beq left.r2         ; already at bottom
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
          .endblock

addrow    .block
          lda scr
          clc
          adc #columns
          bcc f9
          inc scr+1
f9        sta scr
          rts
          .endblock

          ; cursor up routine
up        .block
          lda line            ; check position
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
          .endblock

          ; move window up
topup     .block
          ldy #$ff            ; move text window up line
          dec top+1
b6        dey
          lda (top),y
          beq newtop
          cmp #13
          bne b6
          .endblock

newtop    .block
          sec                 ; add y to top pointer
          tya
          adc top
          bcc f15
          inc top+1
f15       sta top
          jmp window
          .endblock

          ; move window down
topdown   .block
          ldy #$ff
b7        iny
          lda (top),y
          beq newtop
          cmp #13
          bne b7
          beq newtop
          .endblock

          ; initialize for start of new line
unshift   .block
          lda scr
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
          .endblock

          ; move text to screen window
window    bit disflg          ; is display on
          bmi newline.r4      ; no

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
newline   .block
          ldy #$ff
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
          .endblock

addy      .block
          sec                 ; add y to text ptr
          tya
          adc txt
          bcc f19
          inc txt+1
f19       sta txt
          rts
          .endblock

dectxt    .block
          dec txt             ; back up text ptr
          lda txt
          cmp #$ff
          bne f20
          dec txt+1
f20       rts
          .endblock

          ; convert ascii to screen code
cnvscr    .block
          eor #128
          bpl f21
          eor #128
          cmp #64
          bcc f21
          eor #64
f21       rts
          .endblock

reverse   pha                 ; reverse cursor char
          ldy #0
          lda (scr),y
          eor #$80
          sta (scr),y
          pla
          rts

testpos   .block
          lda txt+1           ; test position in text
          cmp end+1
          bcc f22
          bne f22
          lda txt
          cmp end
f22       rts
          .endblock

insert    .block
          lda end+1           ; insert one space
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
          .endblock

pshend    .block
          lda end+1           ; bump end ptr up
          cmp #>bufferend
          bcc f24
          lda end
          cmp #<bufferend
          bcs r5
f24       inc end
          bne r5
          inc end+1
r5        rts
          .endblock

          ; delete character before cursor
deletechr lda #1
          sta num
          jsr left
delete    .block
          lda txt+1           ; number of chars in num
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
          .endblock

          ; insert line
insertln  jsr insert          ; insert chr$(13)
          lda #13
          bne insrtspc.f27

insrtspc  .block
          jsr insert          ; insert blank
          lda #' '
f27       sta (txt),y
          jmp window
          .endblock

          ; delete line
deleteln  .block
          ror disflg          ; display off
          jsr findeoln
          tya
          bne f28
          iny
f28       sty num
          jsr delete
          jmp setwindow
          .endblock

          ; long scroll down
pagedown  .block
          ror disflg          ; no display
          ldx #rows-1         ; 23 lines
b13       jsr down
          dex
          bne b13
          beq setwindow
          .endblock

          ; long scroll up
pageup    .block
          ror disflg          ; no display
          ldx #rows-1         ; 24 lines
b14       jsr up
          dex
          bne b14
          beq setwindow
          .endblock

pageleft  .block
          ror disflg
          ldx #columns-1
b15       jsr left
          dex
          bne b15
          beq setwindow
          .endblock

          ; scroll sideways to end of line
pageright .block
          ror disflg          ; no display
          ldx #columns-1
b16       jsr right
          dex
          bne b16
          .endblock

setwindow lsr disflg
          jmp window          ; display

          ; set y=distance to text eol
findeoln  .block
          ldy #$ff
b17       jsr testeoln
          bne b17
          rts
          .endblock

testeoln  .block
          iny
          cpy #$ff
          beq f29
          lda (txt),y
          beq f29
          cmp #13
f29       rts
          .endblock

initialize .block 
          lda #<bufferbeg
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
          .endblock          
          
initscr   lda #<screenbeg
          sta scr
          lda #>screenbeg
          sta scr+1
          rts

statusline .block
          lda nostatus
          bne done            ; skip status line update
          jsr message
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
done      rts
          .endblock

          ; print in source messages
message   .block
          ldy #0
          pla
          sta ptr
          pla
          sta ptr+1
b19       inc ptr
          bne f33
          inc ptr+1
f33       lda (ptr),y
          beq f34
          jsr chrout
          bne b19
f34       lda ptr+1
          pha
          lda ptr
          pha
          rts
          .endblock

          ; ************* file i/o routines *************

          ; open a seq or prg file and read all data into a buffer.
          ; enter with fnmptr pointing at zero-terminated filename and
          ; bufptr pointing at text buffer. upon return x and y will
          ; hold end-of-buffer address.
readbf    jsr openfl
          jsr readfl
          lda #1
          jsr closfl
          ldx bufptr
          ldy bufptr+1
          rts

          ; open a seq or prg file and write all data from
          ; zero-terminated buffer to the file. enter with fnmptr
          ; pointing at zero-terminated filename and bufptr pointing at
          ; text buffer.
writbf    jsr openfl
          jsr writfl
          lda #1
          jsr closfl
          rts

          ; open a seq or prg file for reading/writing. enter with
          ; fnmptr pointing at zero-terminated filename.
openfl    lda #1
          ldx #8
          ldy #2
          jsr setlfs
          jsr fnamsz
          ldx fnmptr
          ldy fnmptr+1
          jsr setnam
          jsr open
          rts

          ; read a character from a seq or prg file and store in buffer
          ; whose address is in bufptr. enter with bufptr pointing at
          ; text buffer.
readfl    .block
          ldx #1
          jsr chkin
          ldy #0
loop      jsr chrin
          sta (bufptr),y
          inc bufptr
          bne statck
          inc bufptr+1
statck    lda status
          beq loop
          rts
          .endblock
          
          ; write a character to a seq or prg file from zero-terminated
          ; buffer whose address is in bufptr. enter with bufptr
          ; pointing at text buffer.
writfl    .block    
          ldx #1
          jsr chkout
          ldy #0
loop      lda (bufptr),y
          beq done
          jsr chrout
          inc bufptr
          bne more
          inc bufptr+1
more      jmp loop
done      rts
          .endblock     

          ; close the logical file specified in acc and restore device
          ; values.
closfl    jsr close
          jmp clrchn

          ; get size of filename. call with fnmptr set to point to
          ; zero-terminated filename. upon return acc contains size of
          ; filename.
fnamsz    .block
          ldx #0
          ldy #0
loop      lda (fnmptr),y
          beq done
          inx
          inc fnmptr
          bne more
          inc fnmptr+1
more      jmp loop
done      txa
          rts
          .endblock
          
          ; ************* keyboard input *************
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
          sta input,y
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
          sta input,y
          
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
          
          ; prompt for filename & read into memory
loadfile  inc nostatus        ; suspend status line update

          ; todo: clear status line

          jsr message         ; prompt for filename          
          .byte 19            ; (home)
          .text "filename: "
          .byte 0
          
          jsr txtcin          ; read filename from keyboard
          
          ; todo: set fnmptr
          ; todo: call readbf
          ; todo: clear status line 
          
          dec nostatus        ; resume status line updates
          
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
          .byte 136
          .word loadfile-1    ; f7      load file
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
