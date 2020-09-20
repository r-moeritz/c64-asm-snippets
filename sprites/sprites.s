;; use tabwidth=8

.include "../macros.s"

clrscn = $e544
vic = $d000
mib_x2 = vic+4
mib_y2 = vic+5
mib_x_msb = vic+16
mib_enable  = vic+21
mib_pointer = $07f8
mib_mem_sp2 = $0340
joyport2 = $dc00

;; sprite bounding box
min_spritex = $0013		; 19
min_spritey = $32		; 50
max_spritex = $0144		; 324
max_spritey = $e5		; 229


*=$0800

;; encode sys 2064 ($0810) line in basic prg space
.byte $00, $0c, $08, $0a, $00, $9e, $20, $32
.byte $30, $36, $34, $00, $00, $00, $00, $00

;; enable sprite
init	lda #$04
	sta mib_enable		; enable spr. 2
	
	lda #mib_mem_sp2/64	; store start addr. of ptr. 2
	sta mib_pointer+2	; to spr. ptr. register

;; load sprite data	
	ldx #$3f		; max. spr. value => 63
loadspr	lda spr0,x		; load spr. byte
	sta mib_mem_sp2,x	; store to spr. mem.
	dex
	bne loadspr
	dex

;; set sprite position, clear screen	
	lda #100
	sta spritex
	sta spritey
	sta mib_x2
	sta mib_y2	
		
	jsr clrscn

;; move sprite if joystick moved;
;; quit if fire button pressed
readjoy	jsr djrr
	#jcc quit
delay	ldx #$04
loop0	ldy #$ff
loop1	dey
	bne loop1
	dex
	bne loop0
chkmov	lda #1
	cmp dx
	beq mvright
	bcs chky
mvleft	#dbdec spritex
	jmp chkminx
mvright	#dbinc spritex
chkmaxx	#dbcmpi spritex, max_spritex	; check x upper-bound
	beq setsprx			; = x upper-bound
	bcc setsprx			; < x upper-bound
	jmp fixmaxx			; > x upper-bound
chkminx #dbcmpi spritex, min_spritex	; check x lower-bound		
	beq setsprx			; = x lower-bound
	bcs setsprx			; > x lower-bound
fixminx	lda #<min_spritex
	ldx #>min_spritex
	sta spritex
	stx spritex+1
	jmp setsprx
fixmaxx lda #<max_spritex
	ldx #>max_spritex
	sta spritex
	stx spritex+1
setsprx	lda spritex		
	sta mib_x2
	lda spritex+1
	lsr
	rol mib_x_msb
chky	lda #1
	cmp dy
	beq mvdown
	#jcs readjoy
mvup	dec spritey
	jmp chkminy	
mvdown	inc spritey
chkmaxy	lda spritey
	cmp #max_spritey		; check y upper-bound
	beq setspry			; = y upper-bound
	bcc setspry			; < y upper-bound
	jmp fixmaxy			; > y upper-bound
chkminy lda spritey
	cmp #min_spritey		; check y lower-bound
	beq setspry			; = y lower-bound
	bcs setspry			; > y lower-bound
fixminy	lda #min_spritey
	sta spritey
	jmp setspry
fixmaxy lda #max_spritey
	sta spritey
setspry lda spritey
	sta mib_y2
	jmp readjoy
quit	lda #0
	sta mib_enable
	rts	

;;;; read joyport 2 input
;;
;; after calling, dx and dy contain x & y axis movement information:
;;
;; dx=$00		no change on x-axis
;; dx=$01		moved right
;; dx=$ff		moved left
;; dy=$00		no change on y-axis 
;; dy=$01		moved down 
;; dy=$ff		moved up
;;
;; if carry is clear (c=0) then firebutton was pressed 
djrr	lda joyport2
djrrb	ldy #0
	ldx #0
	lsr
	bcs djr0
	dey
djr0	lsr
	bcs djr1
	iny
djr1	lsr
	bcs djr2
	dex
djr2	lsr
	bcs djr3
	inx
djr3	lsr
	stx dx
	sty dy
	rts
	
;; balloon sprite			
spr0	.byte 0,127,0,1,255,192,3,255,224,3,231,224
	.byte 7,217,240,7,223,240,7,217,240,3,231,224
	.byte 3,255,224,3,255,224,2,255,160,1,127,64
	.byte 1,62,64,0,156,128,0,156,128,0,73,0,0,73,0,0
	.byte 62,0,0,62,0,0,62,0,0,28,0

;; joystick x & y dir
;; TODO move to zero-page
dx	.byte 0	
dy	.byte 0

;; sprite x & y positions
;; TODO move to zero-page
spritex	.word $0000
spritey .byte $00