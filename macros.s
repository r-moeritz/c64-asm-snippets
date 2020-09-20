; useful general-purpose and 16-bit macros

;; 2-byte increment
;; \1	memory location (lo-byte) to increment
dbinc	.macro
	lda \1
	clc
	adc #1
	sta \1
	lda #0
	adc \1+1
	sta \1+1
	.endm

;; 2-byte decrement
;; \1	memory location (lo-byte) to decrement
dbdec	.macro
	lda \1
	sec
	sbc #1
	sta \1
	lda \1+1
	sbc #0
	sta \1+1
	.endm

;; 2-byte cmp a memory location with a 16-bit number (same semantics as regular cmp ins.)
;; \1	first memory location (lo-byte) to compare (equiv. to a)	
;; \2	16-bit number
dbcmpi	.macro
	lda \1+1
	cmp #>\2
	bcc done
	bne done
	lda \1
	cmp #<\2
done	nop
	.endm

;; jmp to address if c=0
;; \1	address to jmp to if c=0
jcc	.macro
	bcs done
	jmp \1
done	nop
	.endm

;; jmp to address if c=1
;; \1	address to jmp to if c=1
jcs	.macro
	bcc done
	jmp \1
done	nop
	.endm

;; jmp to address if z=1
;; \1	address to jmp to if z=1
jeq	.macro
	bne done
	jmp \1
done	nop
	.endm

;; jmp to address if z=0
;; \1	address to jmp to if z=0
jne	.macro
	beq done
	jmp \1
done	nop
	.endm
