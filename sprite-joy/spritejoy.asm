.include "../shared/macros.asm"

; --------------------------------------------------------
;  memory addresses
; --------------------------------------------------------

; joystick 2 coordinates
joy2x = $009e
joy2y = $009f

cinv = $0314                    ; irq vector
sp0ptr = $07f8                  ; pointer to sprite 0

; vic-ii memory
vic = $d000
sp2x = vic+$04
sp2y = vic+$05
msigx = vic+$10
scroly = vic+$11
raster = vic+$12
vicirq = vic+$19
irqmsk = vic+$1a
spena  = vic+$15

; i/o
ciapra = $dc00
ciaicr = $dc0d

; kernal routines
clrscn = $e544
sysirq = $ea31
restore = $ea7e

; --------------------------------------------------------
; constants
; --------------------------------------------------------

rasterln = $fa                  ; line for raster irq

; sprite bounding box
minspx = $0013
minspy = $32
maxspx = $0144
maxspy = $e5

; --------------------------------------------------------
; code start
; --------------------------------------------------------

* = $0801

                .word (+), 2005                 ; pointer, line number
                .null $9e, format("%4d", init)  ; sys <decimal address of init>
+               .word 0                         ; basic line end                

; enable sprite
init            lda #%00000100
                sta spena                       ; enable sprite 2

                lda #sp2data/64                 ; store address of sprite 2 shape
                sta sp0ptr+2                    ; in sprite pointer register

                ; set sprite position, clear screen
                lda #100
                sta sp2posx
                sta sp2posy
                sta sp2x
                sta sp2y
                
                jsr clrscn
        
                ; set interrupt handler, enable raster interrupt
                sei
                lda #<newirq
                sta cinv
                lda #>newirq
                sta cinv+1
                lda #rasterln
                sta raster
                lda scroly
                and #%01111111                  ; erase highbyte
                sta scroly
                lda #%10000001                  ; enable raster interrupt
                sta irqmsk
                cli
        
                ; move sprite if joystick moved, quit if fire button pressed
readjoy         jsr rdjoy2
                #jcc quit
delay           ldx #$03
loop0           ldy #$ff
loop1           dey
                bne loop1
                dex
                bne loop0
chkmov          lda #1
                cmp joy2x
                beq mvright
                bcs chky
mvleft          #dec_word sp2posx
                jmp chkminx
mvright         #inc_word sp2posx
chkmaxx         #cmp_word_i sp2posx, maxspx     ; check x upper-bound
                beq readjoy                     ; = x upper-bound
                bcc readjoy                     ; < x upper-bound
                bcs fixmaxx                     ; > x upper-bound
chkminx         #cmp_word_i sp2posx, minspx     ; check x lower-bound
                jeq readjoy                     ; = x lower-bound
                #jcs readjoy                     ; > x lower-bound
fixminx         lda #<minspx
                ldx #>minspx
                sta sp2posx
                stx sp2posx+1
                jmp readjoy
fixmaxx         lda #<maxspx
                ldx #>maxspx
                sta sp2posx
                stx sp2posx+1
chky            lda #1
                cmp joy2y
                beq mvdown
                jcs readjoy
mvup:           dec sp2posy
                jmp chkminy
mvdown:         inc sp2posy
chkmaxy:        lda sp2posy
                cmp #maxspy                     ; check y upper-bound
                jeq readjoy                     ; = y upper-bound
                jcc readjoy                     ; < y upper-bound
                jmp fixmaxy                     ; > y upper-bound
chkminy:        lda sp2posy
                cmp #minspy                     ; check y lower-bound
                jeq readjoy                     ; = y lower-bound
                jcs readjoy                     ; > y lower-bound
fixminy         lda #minspy
                sta sp2posy
                jmp readjoy
fixmaxy         lda #maxspy
                sta sp2posy
                jmp readjoy
quit:           lda #0
                sta spena                       ; disable all sprites
                rts

                ; interrupt handler
newirq          lda vicirq
                sta vicirq                      ; erase irq reg.
                bmi rasirq

                ; system interrupt
                lda ciaicr                      ; erase cia 1 irq reg.
                cli
                jmp sysirq

                ; raster interrupt
rasirq          lda raster
                cmp #rasterln
                beq setsprx
                jmp exitirq
setsprx         lda sp2posx
                sta sp2x
setxmsb         lda sp2posx+1
                beq clrxmsb
                lda msigx
                ora #%00000100
                sta msigx
                jmp setspry
clrxmsb         lda msigx
                and #%11111011
                sta msigx
setspry         lda sp2posy
                sta sp2y
exitirq         jmp restore

; --------------------------------------------------------
; read joyport 2 input
;
; after calling, joy2x and joy2y contain 
; x & y axis movement information
;
; joy2x = $00   no change on x-axis
; joy2x = $01   moved right
; joy2x = $ff   moved left
; joy2y = $00   no change on y-axis
; joy2y = $01   moved down
; joy2y = $ff   moved up
;
; if carry is clear (c=0) then firebutton was pressed
; --------------------------------------------------------
rdjoy2          lda ciapra
djrrb           ldy #0
                ldx #0
                lsr
                bcs djr0
                dey
djr0            lsr
                bcs djr1
                iny
djr1            lsr
                bcs djr2
                dex
djr2            lsr
                bcs djr3
                inx
djr3            lsr
                stx joy2x
                sty joy2y
                rts

                ; sprite 2 coordinates
sp2posx         .word $0000
sp2posy         .byte $00
        
                ; balloon sprite
                .align 64
sp2data         .byte 0,127,0,1,255,192,3,255,224,3,231,224
                .byte 7,217,240,7,223,240,7,217,240,3,231,224
                .byte 3,255,224,3,255,224,2,255,160,1,127,64
                .byte 1,62,64,0,156,128,0,156,128,0,73,0,0,73,0,0
                .byte 62,0,0,62,0,0,62,0,0,28,0
