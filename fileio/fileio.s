	.const setlfs = $ffba
	.const setnam = $ffbd
	.const open = $ffc0
	.const chkin = $ffc6
	.const chrin = $ffcf
	.const close = $ffc3
	.const clrchn = $ffcc
	.const status = $90
	.const zp = $fb
	.const buffer = $0801
	.const fnam = "0:sequentials,s,r"

	*= $c000

main:
	ldx #<buffer
	ldy #>buffer
	jsr readbf
	rts

	// open a seq or prg file and read all data into a buffer.
	// enter with address of storage buffer in x (lo) and y (hi).
	// upon return x and y will hold end-of-buffer address.
readbf:
	stx zp
	sty zp+1
	jsr openfl
	jsr readfl
	lda #1
	jsr closfl
	ldx zp
	ldy zp+1
	rts

	// open a seq or prg file for reading/writing.
openfl:
	lda #1
	ldx #8
	ldy #2
	jsr setlfs
	lda #fnleng
	ldx #<filenm
	ldy #>filenm
	jsr setnam
	jsr open
	rts

	// read a character from a seq or prg file and store in buffer
	// whose address is in zp.
readfl:
	ldx #1
	jsr chkin
	ldy #0
rdloop:
	jsr chrin
	sta (zp),y
	inc zp
	bne statck
	inc zp+1
statck:
	lda status
	beq rdloop
	rts

	// close the logical file specified in acc and restore device
	// values.
closfl:
	jsr close
	jmp clrchn

filenm:	.text fnam
fnleng:	.byte fnam.size()
