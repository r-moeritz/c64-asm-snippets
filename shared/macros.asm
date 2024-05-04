; +------------------------------------------+ 
; | useful general-purpose and 16-bit macros |
; +------------------------------------------+

; 16-bit operations
; -------------------------------------------------------------

; increment a word
; lo = low byte of word address
inc_word        .macro lo
                lda \lo
                clc
                adc #1
                sta \lo
                lda #0
                adc \lo+1
                sta \lo+1
                .endm

; decrement a word
; lo = low byte of word address
dec_word        .macro lo
                lda \lo
                sec
                sbc #1
                sta \lo
                lda \lo+1
                sbc #0
                sta \lo+1
                .endm

; compare a word to a 16-bit value in immediate mode
; lo = low byte of word address
; wrd = literal 16-bit value to compare against
cmp_word_i      .macro lo, wrd
                lda \lo+1
                cmp #>\wrd
                bcc fin
                bne fin
                lda \lo
                cmp #<\wrd
fin             .endm

; add a byte to a word
; lo = low byte of word address
; byt = byte to add
adc_word        .macro lo, byt
                lda \lo
                clc
                adc \byt
                sta \lo
                lda #0
                adc \lo+1
                sta \lo+1
                .endm

; add two words
; lo1 = low byte of 1st word address
; lo2 = low byte of 2nd word address
adc_words       .macro lo1, lo2
                lda \lo1
                clc
                adc \lo2
                sta \lo1
                lda \lo2+1
                adc \lo1+1
                sta \lo1+1
                .endm
          
; subtract a byte from a word
; lo = low byte of word address
; byt = byte to subtract
sbc_word        .macro lo, byt
                lda \lo
                sec
                sbc \byt
                sta \lo
                lda \lo+1
                sbc #0
                sta \lo+1
                .endm
          
; subtract one word from another
; lo1 = low byte of 1st word address
; lo2 = low byte of 2nd word address
sbc_words       .macro lo1, lo2
                lda \lo1
                sec
                sbc \lo2
                sta \lo1
                lda \lo1+1
                sbc \lo2+1
                sta \lo1+1
                .endm    

; conditional jumps
; -------------------------------------------------------------

jcc       .macro adr
          bcs fin
          jmp \adr
fin       .endm

jcs       .macro adr
          bcc fin
          jmp \adr
fin       .endm

jeq       .macro adr
          bne fin
          jmp \adr
fin       .endm

jne       .macro adr
          beq fin
          jmp \adr
fin       .endm

; vector methods
; -------------------------------------------------------------

; add vector v1 to vector v2
adc_vectors     .macro v1, v2
                #adc_words v1.x, v2.x          
                lda v1.y
                clc
                adc v2.y
                sta v1.y
                .endm

; substract vector v2 from vector v1
sbc_vectors     .macro v1, v2
                #sbc_words v1.x, v2.x
                lda v1.y
                sec
                sbc v2.y
                sta v1.y
                .endm
                
; low-res functions
; -------------------------------------------------------------

; set background and border colours.                
; bor = border colour (0-15) 
; bak = background colour (0-15) 
set_bg_colours  .macro bor, bak
                ldx \bor
                cpx #16
                #jcs illqua
                ldy \bak
                cpx #16
                #jcs illqua
                stx vic+$20
                sty vic+$21
                .endm

; clear the low-res screen                
clear_screen    .macro
                lda #$93
                jsr bsout
                .endm