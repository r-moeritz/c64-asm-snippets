;-----------------------
; vic raster irq example
;-----------------------

; memory locations
; ----------------
vic = $d000
newvic = $c100
cia1icr = $dc0d
cia2icr = $dd0d
scroly = $d011
vicirq = $d019
irqmsk = $d01a
border = $d020
raster = $d012
irqvec = $0314
irqnor = $ea31
irqend = $ea81

; values
; ------
gray3 = 15
green = 5

*= $c000

; disable all interrupts
; ----------------------
          sei
          lda #$7f
          sta cia1icr                   ; disable cia1 irqs
          sta cia2icr                   ; disable cia2 irqs
          ldy #0
          sty irqmsk                    ; clear irq mask
          sty vicirq                    ; disable vic irqs
          lda vicirq                    ; disable last vic irq
          lda cia1icr                   ; disable last cia1 irq
          lda cia2icr                   ; disable last cia2 irq
          
; make 2 copies of vic registers $d000 to $d02e at $c100 and $c12f
; ----------------------------------------------------------------
          ldy #$2e
loop      lda vic,y
          sta newvic,y
          sta newvic+47,y
          dey
          bpl loop
          
; setup interrupts
; ----------------
          lda #<int1
          sta irqvec
          lda #>int1
          sta irqvec+1
          
          lda scroly                    ; clearing bit 7 of $d011 actually         
          and #$7f                      ; clears  bit 8 of $d012 
          sta scroly                    ; (raster compare register)
          
          sta newvic+$11                ; also clear it in both vic
          sta newvic+$11+47             ; register copies
          
          lda #148                      ; irq after next to occur at scanline 148
          sta newvic+$12
          lda #1                        ; next irq to occur at scanline 1
          sta raster
          sta newvic+$12+47
          
          lda #$81                      ; also set $d019 and $d01a here
          sta newvic+$19
          sta newvic+$19+47
          sta newvic+$1a
          sta newvic+$1a+47
          sta vicirq
          sta irqmsk
          
          cli
          rts
          
int1      ldy #$2e
          lda raster
          cmp #148
          bcc int2
          ldy #$2e+47
          
int2      ldx #$2e

int3      lda newvic,y
          sta vic,x
          dey
          dex
          bpl int3
          
          tya                           ; if y<0 then newvic1 else newvic2
          bpl int4
          lda #gray3                    ; newvic1: jump to regular irq vector
          sta border
          jmp irqnor
          
int4      lda #green                    ; newvic2: just end interrupt
          sta border
          jmp irqend
