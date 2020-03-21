;***********************************************
; full-screen editor, heavily inspired by
; hypra-editor by michael kueper
;***********************************************

    .org $7000

;***********************************************
; os vectors
;***********************************************

CHRGET       = $0073
CHRGOT       = $0079
SETSTRING    = $AB1E
READY        = $A474
ZEILBIND     = $A533
ZEILSUCH     = $A613
EINGEBEN     = $A560
INDEX        = $A67A
ZEIGSTART    = $A68E
BLOCKVER     = $A3BF
ZEILLOESCH   = $A4A9
ZAHLIN       = $A96B
SGNIN        = $BC49
FACASC       = $BDDF
INTOUT       = $BDCD
BICLEAR      = $E544
PLOT         = $E50C
ZEIOUT       = $EA13
GETPUF       = $E5B4
BIRECH       = $E6ED
BILDIN1      = $E63A
BILDIN2      = $E65D
AUSGABEB1    = $E6A8
QUOTETEST    = $E684
DELETE       = $E75C
FARBTEST     = $E8CB
STEUERTEST   = $EC44
INSERTB      = $E807
STEUERTEST2  = $EC4F
BILDRECH     = $E9F0
LOESCHZEIL   = $E9FF
ZEILUP       = $E9C8
PLOTBILD     = $EA1C
SAVEB        = $E159
GETPAR       = $E257
LISTEN       = $ED0C
SEKLIST      = $EDB9
IECOUT       = $EDDD
TESTSTOP     = $FFE1
LOADB        = $FFD5
REGISTER     = $FEBC
TASTSTOP     = $F6BC
SETIOVEK     = $FD15
INTINIT      = $FDA3
IECOPEN      = $F3D5
SETZEIGER    = $FB8E
SAVEIN       = $F624
FILPAR       = $FFBA
TALK         = $FFB4
SEKTALK      = $FF96
IECIN        = $FFA5
BSOUT        = $FFD2
IECCLOSE     = $F642

;***********************************************
; flags and markers
;***********************************************

FLAG         = $02C0
ZEILSTART    = $02C1
ZEILEND      = $02C2
STARTZEIL    = $02C3
ENDZEIL      = $02C4
MERKER       = $02C5
MERKER1      = $02C8
BLOCKANF     = $02CE
BLOCKEND     = $02D0
LISTEND      = $02D3
BLOCKFARBE   = $02D4
LISTFARBE    = $02D5
ZEILE        = $F9

;***********************************************
; initialization
;***********************************************

INITIAL:        CLI               
                LDY #$03          
INITLOOP1:      LDA VEKTOREN1,Y   
                STA $0300,Y       
                DEY               
                BPL INITLOOP1     
                LDY #$03          
INITLOOP2:      LDA VEKTOREN2,Y   
                STA $0324,Y       
                DEY               
                BPL INITLOOP2     
                LDA #<(NMI)       
                STA $0318         
                LDA #>(NMI)       
                STA $0319         
                LDA #$80          
                STA FLAG          
                JSR NULLZEILE     
                STA $D021         
                LDA #$02          
                STA $D020         
                STA BLOCKFARBE    
SCHRIFT:        LDA #$07          
                STA $0286         
                STA LISTFARBE     
BILDGROESSE:    STY ZEILSTART     
                LDA #$05          
                STA STARTZEIL     
                LDA #$27          
                STA ZEILEND       
                LDA #$18          
                STA ENDZEIL       
                JSR BICLEAR       
KOPFSET:        LDY #201          
KOPFLOOP:       LDA KOPF-1,Y      
                STA $03FF,Y       
                DEY               
                BNE KOPFLOOP      
KOPFEND:        JSR BINDNUMLI     
                JSR LASTZEIL      
NOPROG:         JSR INDEX         
                JMP NONEWZ
                
;***********************************************
; input routine
;***********************************************

NEUEINL:        LDA $D3           
                STA $CA           
                LDA $D6           
                STA $C9           
                JMP BILDIN

;***********************************************
; nmi routine
;***********************************************

NMI:            PHA               
                TXA               
                PHA               
                TYA               
                PHA               
                LDA #$7F          
                STA $DD0D         
                JSR TASTSTOP      
                JSR TESTSTOP      
                BNE NOSTOP2       
                JMP INITIAL       
NOSTOP2:        JMP REGISTER

