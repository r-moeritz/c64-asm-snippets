          setlfs = $ffba
          setnam = $ffbd
          open = $ffc0
          chkin = $ffc6
          chkout = $ffc9
          chrin = $ffcf
          chrout = $ffd2
          close = $ffc3
          clrchn = $ffcc
          status = $90        

          bufsz = $4000       ; size of text buffer: 16K
          bufptr = $fb        ; pointer to text buffer
          fnmptr = $fd        ; pointer to zero-terminated filename

          *= $c000

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
          .bend
          
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
          .bend     

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
          .bend
