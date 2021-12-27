#import "../macros.s"

            //--------------------------------------------------------
            // memory addresses
            //--------------------------------------------------------

            // joystick 2 coordinates
            .const joy2x = $009e
            .const joy2y = $009f

            .const cinv = $0314			// irq vector
            .const sp0ptr = $07f8       // pointer to sprite 0

            // vic-ii memory
            .const vic = $d000
            .const sp2x = vic+$04
            .const sp2y = vic+$05
            .const msigx = vic+$10
            .const scroly = vic+$11
            .const raster = vic+$12
            .const vicirq = vic+$19
            .const irqmsk = vic+$1a
            .const spena  = vic+$15

            // i/o
            .const ciapra = $dc00
            .const ciaicr = $dc0d

            // kernal routines
            .const clrscn = $e544
            .const sysirq = $ea31
            .const restore = $ea7e

            //--------------------------------------------------------
            // constants
            //--------------------------------------------------------

            .const rasterln = $fa       // line for raster irq

            // sprite bounding box
            .const minspx = $0013
            .const minspy = $32
            .const maxspx = $0144
            .const maxspy = $e5

            //--------------------------------------------------------
            // code start
            //--------------------------------------------------------

            *= $0800

                BasicUpstart2(init)

                // enable sprite
init:           lda #%00000100
	            sta spena               // enable sprite 2

	            lda #sp2data/64             // store address of sprite 2 shape
	            sta sp0ptr+2            // in sprite pointer register

                // set sprite position, clear screen
	            lda #100
	            sta sp2posx
	            sta sp2posy
	            sta sp2x
	            sta sp2y
		
	            jsr clrscn
	
                // set interrupt handler, enable raster interrupt
	            sei
	            lda #<newirq
	            sta cinv
	            lda #>newirq
	            sta cinv+1
	            lda #rasterln
	            sta raster
	            lda scroly
	            and #%01111111          // erase highbyte
	            sta scroly
	            lda #%10000001          // enable raster interrupt
	            sta irqmsk
	            cli
	
                // move sprite if joystick moved, quit if fire button pressed
readjoy:        jsr rdjoy2
	            jcc quit
delay:          ldx #$03
loop0:          ldy #$ff
loop1:          dey
	            bne loop1
	            dex
	            bne loop0
chkmov:         lda #1
	            cmp joy2x
	            beq mvright
	            bcs chky
mvleft:	        dbdec(sp2posx)
	            jmp chkminx
mvright:	    dbinc(sp2posx)
chkmaxx:	    dbcmpi(sp2posx, maxspx)	// check x upper-bound
	            beq readjoy             // = x upper-bound
	            bcc readjoy             // < x upper-bound
	            bcs fixmaxx             // > x upper-bound
chkminx:        dbcmpi(sp2posx, minspx)	// check x lower-bound
                jeq readjoy             // = x lower-bound
	            jcs readjoy             // > x lower-bound
fixminx:        lda #<minspx
	            ldx #>minspx
	            sta sp2posx
	            stx sp2posx+1
	            jmp readjoy
fixmaxx:        lda #<maxspx
	            ldx #>maxspx
	            sta sp2posx
	            stx sp2posx+1
chky:           lda #1
	            cmp joy2y
	            beq mvdown
	            jcs readjoy
mvup:           dec sp2posy
	            jmp chkminy
mvdown:         inc sp2posy
chkmaxy:        lda sp2posy
	            cmp #maxspy             // check y upper-bound
	            jeq readjoy             // = y upper-bound
	            jcc readjoy             // < y upper-bound
	            jmp fixmaxy             // > y upper-bound
chkminy:        lda sp2posy
	            cmp #minspy             // check y lower-bound
	            jeq readjoy             // = y lower-bound
	            jcs readjoy             // > y lower-bound
fixminy:        lda #minspy
	            sta sp2posy
	            jmp readjoy
fixmaxy:        lda #maxspy
	            sta sp2posy
	            jmp readjoy
quit:           lda #0
	            sta spena               // disable all sprites
	            rts

// interrupt handler
newirq:         lda vicirq
	            sta vicirq              // erase irq reg.
	            bmi rasirq

                // system interrupt
	            lda ciaicr              // erase cia 1 irq reg.
	            cli
	            jmp sysirq

            // raster interrupt
rasirq:         lda raster
	            cmp #rasterln
	            beq setsprx
	            jmp exitirq
setsprx:        lda sp2posx
	            sta sp2x
setxmsb:        lda sp2posx+1
	            beq clrxmsb
	            lda msigx
	            ora #%00000100
	            sta msigx
	            jmp setspry
clrxmsb:        lda msigx
	            and #%11111011
	            sta msigx
setspry:        lda sp2posy
	            sta sp2y
exitirq:        jmp restore

//// read joyport 2 input
//
// after calling, joy2x and joy2y contain x & y axis movement information:
//
// joy2x=$00		no change on x-axis
// joy2x=$01		moved right
// joy2x=$ff		moved left
// joy2y=$00		no change on y-axis
// joy2y=$01		moved down
// joy2y=$ff		moved up
//
// if carry is clear (c=0) then firebutton was pressed
rdjoy2:         lda ciapra
djrrb:          ldy #0
	            ldx #0
	            lsr
	            bcs djr0
	            dey
djr0:           lsr
	            bcs djr1
	            iny
djr1:           lsr
	            bcs djr2
	            dex
djr2:           lsr
	            bcs djr3
	            inx
djr3:           lsr
	            stx joy2x
	            sty joy2y
	            rts

                // sprite 2 coordinates
sp2posx:        .word $0000
sp2posy:        .byte $00

                *= *+$0c                // skip 12 bytes to ensure sp2data is divisible by 64
	
                // balloon sprite
sp2data:        .byte 0,127,0,1,255,192,3,255,224,3,231,224
	            .byte 7,217,240,7,223,240,7,217,240,3,231,224
	            .byte 3,255,224,3,255,224,2,255,160,1,127,64
	            .byte 1,62,64,0,156,128,0,156,128,0,73,0,0,73,0,0
	            .byte 62,0,0,62,0,0,62,0,0,28,0
