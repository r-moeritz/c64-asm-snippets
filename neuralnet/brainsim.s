#import "../macros.s"

            .encoding "petscii_mixed"

            // kernal routines
            .const getin = $ffe4
            .const chrout = $ffd2

            // zp
            .const ptr = $fa

            .macro draw_border(r1, c1) {
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

            .macro print_spaces(n) {
                lda #' '

                .for (var i=0; i<n; i++) {
                    jsr chrout
                }
            }

            .macro print_char_i(chr) {
                lda #chr
                jsr chrout
            }

            .macro print_char(adr) {
                lda adr
                jsr chrout
            }

            .macro print_str(str) {
                lda #<str
                ldx #>str
                sta ptr
                stx ptr+1
                jsr print_ptr
            }

            .macro clear_screen() {
                print_char_i($93)
            }

                *= $0801

                BasicUpstart2(init)

                // Screen configuration
init:           lda #13                 // Set
                ldx #6                  // border
                sta $d020               // and
                stx $d021               // background

                clear_screen()

                print_str(prompt)

                draw_border(4, 5)
                draw_border(4, 25)

                jsr update_f2_on_screen
                jsr update_f1_on_screen

read_input:     jsr position_to_status_area

                print_str(ready)
                jsr read_char

                jsr position_to_status_area
                print_spaces(10)

                .var k=a
                lda a
                cmp #$85                // Check if
                bcc not_fkey            // F-key was
                cmp #$8d                // pressed
                bcs not_fkey            // and
                jsr dispatch_fkey       // dispatch

                rts

not_fkey:       cmp #$30
                bcc not_digit
                cmp #$3a
                bcs not_digit
                .eval k += 64
                jmp echo_char

not_digit:      cmp #$41
                jcc read_input
                cmp #$5b
                jcs read_input

echo_char:      jsr position_to_status_area
                print_str(fetch)
                print_char(a)

                rts

dispatch_fkey: {
                sec
                sbc #132

                cmp #1
                jeq train_on_pattern_in_f1

                // TODO

                rts
}

read_char: {
loop:           jsr getin
                beq loop
                sta a

                rts
}

print_ptr: {
                ldy #0
getchr:         lda (ptr),y
                beq done
                jsr chrout
                iny
                jmp getchr

done:           rts
}

update_f2_on_screen: {
                ldx #0

                .var v
                .for (var i=0; i<7; i++) {
                    .eval v = $0400+$28*(i+5)+6
                    .for (var j=2; j<8; j++) {
                        inx
                        lda f1,x
                        bne space
dot:                    lda #$51
                        jmp putchr
space:                  lda #$20
putchr:                 sta v+8-j
                    }
                }

                rts
}

update_f1_on_screen: {
                ldx #0

                .var v
                .for (var i=0; i<7; i++) {
                    .eval v = $0400+$28*(i+5)+26
                    .for (var j=2; j<8; j++) {
                        inx
                        lda f2,x
                        bne space
dot:                    lda #$51
                        jmp putchr
space:                  lda #$20
putchr:                 sta v+8-j
                    }
                }

                rts
}

train_on_pattern_in_f1: {
                jsr position_to_status_area

                print_str(training)

                // TODO
}

position_to_status_area: {
                lda #$13
                jsr chrout

                lda #$11
                ldx #21
prtchr:         jsr chrout
                dex
                bne prtchr
                rts
}

            // Variable declarations
a:              .byte 0
f1:             .fill 42, 0
f2:             .fill 42, 0
m:              .fill 42*42, 0
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
                .byte 0
ready:          .text " ready    "
                .byte 0
fetch:          .text "fetch "
                .byte 0
training:       .text "training"
                .byte 0
