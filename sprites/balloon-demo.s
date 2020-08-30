clrscn	= $e544
vic	= $d000
mib_x2	= vic+4
mib_y2	= vic+5
mib_y_msb	= vic+16
mib_enable  = vic+21
mib_pointer = $07f8
mib_mem_sp2 = $0340

*=$0800

;; encode sys 2064 ($0810) line
;; in basic prg space
.byte $00, $0c, $08, $0a, $00, $9e, $20, $32
.byte $30, $36, $34, $00, $00, $00, $00, $00

init	lda #$04
	sta mib_enable	; enable spr. 2
	
	lda #mib_mem_sp2/64	; store start addr. of ptr. 2
	sta mib_pointer+2	; to spr. ptr. register
	
	ldx #$3f		; max. spr. value => 63
x0	lda spr0,x	; load spr. byte
	sta mib_mem_sp2,x	; store to spr. mem.
	dex
	bne x0
	dex
	stx mib_x2
	stx mib_y2
	
	jsr clrscn
	
y0	inc mib_x2
	inc mib_y2
	
	;; delay for spr. move
	ldx #$09		; set prescaler outer loop
y11	ldy #$ff		; set prescaler inner loop		
y1	dey		
	bne y1		
	dex		
	bne y11		
			
	lda mib_x2		
	cmp #$c8		; has spr. pos. reached 200?		
	bne y0		
			
	rts		
	
;; balloon sprite			
spr0	.byte 0,127,0,1,255,192,3,255,224,3,231,224
	.byte 7,217,240,7,223,240,7,217,240,3,231,224
	.byte 3,255,224,3,255,224,2,255,160,1,127,64
	.byte 1,62,64,0,156,128,0,156,128,0,73,0,0,73,0,0
	.byte 62,0,0,62,0,0,62,0,0,28,0

	