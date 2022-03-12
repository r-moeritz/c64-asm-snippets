            // memory locations
            .const vic = $d000
            .const newvic = $c100
            .const cia1icr = $dc0d
            .const cia2icr = $dd0d
            .const scroly  = $d011
            .const vicirq = $d019
            .const irqmsk = $d01a
            .const border = $d020
            .const raster = $d012
            .const irqvec = $0314
            .const irqnor = $ea31
            .const irqend = $ea81

            // values
            .const gray3 = 15
            .const green =  5

            *= $c000

                // disable all interrupts
                sei                     // ignore all irqs
                lda #$7f
                sta cia1icr             // disable cia1 irqs
                sta cia2icr             // disable cia2 irqs
                ldy #0
                sty irqmsk              // clear irq mask
                sty vicirq              // disable vic irqs
                lda vicirq              // disable last vic irq
                lda cia1icr             // disable last cia1 irq
                lda cia2icr             // disable last cia2 irq

                // make 2 copies of vic registers $d000-$d02e at $c100 and $c12f
                ldy #$2e
loop:           lda vic,y
                sta newvic,y
                sta newvic+47,y
                dey
                bpl loop

                // setup interrupts
                lda #<int1              // setup irq vector
                sta irqvec
                lda #>int1
                sta irqvec+1

                lda scroly              // clearing bit 7 of $d011 actually clears ...
                and #$7f                // bit 8 of $d012 (raster compare register)
                sta scroly
                sta newvic+$11          // also clear it in both vic register copies
                sta newvic+$11+47
                lda #148                // irq after next should occur at scanline #148
                sta newvic+$12
                lda #1                  // next irq should occur at scanline #1
                sta raster
                sta newvic+$12+47       // ... so should the irq after next

                lda #$81                // also set $d019 and $d01a here
                sta newvic+$19
                sta newvic+$19+47
                sta newvic+$1a
                sta newvic+$1a+47
                sta vicirq
                sta irqmsk

                cli
                rts

int1:           ldy #$2e
                lda raster
                cmp #148
                bcc int2
                ldy #$2e+47

int2:           ldx #$2e

int3:           lda newvic,y
                sta vic,x
                dey
                dex
                bpl int3

                tya                     // y<0: newvic #1, else newvic #2
                bpl int4
                lda #gray3              // at 1st newvic, jump to regular irq vector
                sta border
                jmp irqnor

int4:           lda #green              // at 2nd newvic, just end interrupt
                sta border
                jmp irqend
