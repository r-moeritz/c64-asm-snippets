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

                rts

                // Variable declarations
f1:             .fill 42, 0
f2:             .fill 42, 0
m:              .fill 42*42,0
v:              .byte 0
j:              .word 0
i:              .word 0
prompt:         .text @"    neuron network associative memory\n\n"
                .fill 12,$11            // cursor down
                .text "f1 - teach pattern     "
                .text @"f2 - dump matrixq\n"
                .text "f3 - randomize pattern "
                .text @"f4 - forget all\n"
                .text "f5 - recall pattern    "
                .text @"f6 - quit\n"
                .text "f7 - disc save         "
                .text @"f8 - disc load\n\n"
                .text @"a-z, 0-9: load pattern\n"
promptEnd:
