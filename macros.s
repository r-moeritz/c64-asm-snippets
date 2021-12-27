            // useful general-purpose and 16-bit macros

            // 2-byte increment
            // lo: memory location (low-byte) to increment
            .macro dbinc(lo) {
                lda lo
	            clc
	            adc #1
	            sta lo
	            lda #0
	            adc lo+1
	            sta lo+1
            }

            // 2-byte decrement
            // lo: memory location (low-byte) to decrement
            .macro dbdec(lo) {
	            lda lo
	            sec
	            sbc #1
	            sta lo
	            lda lo+1
	            sbc #0
	            sta lo+1
            }

            // 2-byte cmp a memory location with a 16-bit number (same semantics as regular cmp ins.)
            // lo: first memory location (low-byte) to compare (equiv. to a)
            // wrd: 16-bit number
            .macro dbcmpi(lo,wrd) {
                lda lo+1
	            cmp #>wrd
	            bcc done
	            bne done
	            lda lo
	            cmp #<wrd
done:
            }

            // jmp to address if c=0
            // adr: address to jmp to if c=0
            .pseudocommand jcc adr {
	            bcs done
	            jmp adr
done:
            }

            // jmp to address if c=1
            // adr:	address to jmp to if c=1
            .pseudocommand jcs adr {
                bcc done
	            jmp adr
done:
            }

            // jmp to address if z=1
            // adr:	address to jmp to if z=1
            .pseudocommand jeq adr {
                bne done
	            jmp adr
done:
            }

            // jmp to address if z=0
            // adr:	address to jmp to if z=0
            .pseudocommand jne adr {
                beq done
	            jmp adr
done:
            }
