#import "../macros.s"

                .encoding "petscii_mixed"

                .const bsout = $ffd2

                *= $c000

                // Screen configuration
                lda #13                 // Set
                ldx #6                  // border
                sta $d020               // and
                stx $d021               // background

                lda #$93                // Clear
                jsr bsout               // screen

printPrompt:    lda prompt
                jsr bsout
                dbinc(printPrompt+1)
                lda printPrompt+2
                cmp #>promptEnd
                bne printPrompt
                lda printPrompt+1
                cmp #<promptEnd
                bne printPrompt

                drawBorder(4, 5)
                drawBorder(4, 25)

                rts

            .macro drawBorder(r1,c1) {
                .var v
                .var vv
                .for (var i=0; i<2; i++) {
                    .eval v = $0400+$28*(r1+i*8)+c1
                    .eval vv = $70-3*i
                    lda #vv
                    sta v

                    .for (var j=1; j<9; j++) {
                        lda #$43
                        sta v+j
                    }

                    .eval vv = $6e+$f*i
                    lda #vv
                    sta v+9
                }

                .for (var i=1; i<8; i++) {
                    .eval v = $0400+$28*(r1+i)+c1
                    lda #$5d
                    sta v
                    sta v+9
                }
            }
                
                // Variable declarations
f1:             .fill 42, 0
f2:             .fill 42, 0
m:              .fill 42*42, 0
v:              .byte 0
j:              .word 0
i:              .word 0
prompt:         .text @"    neuron network associative memory\n\n"
                .fill 12, $11            // cursor down 12 times
                .text "f1 - teach pattern     "
                .text @"f2 - dump matrix\n"
                .text "f3 - randomize pattern "
                .text @"f4 - forget all\n"
                .text "f5 - recall pattern    "
                .text @"f6 - quit\n"
                .text "f7 - disc save         "
                .text @"f8 - disc load\n\n"
                .text @"a-z, 0-9: load pattern\n"
promptEnd:
