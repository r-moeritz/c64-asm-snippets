;<edi.s> ==1FD8==
;HYPRA-EDITOR V1.1/1986
;
;     MICHAEL KUEPER
;     WINKELN 21
;5885 SCHALKSMUEHLE
;
;
;
         .BA $1FD8         
;
;-- BENUTZTE BETRIEBSSYSTEM-ROUTINEN --
;
.EQ CHRGET       = $0073
.EQ CHRGOT       = $0079
.EQ SETSTRING    = $AB1E
.EQ READY        = $A474
.EQ ZEILBIND     = $A533
.EQ ZEILSUCH     = $A613
.EQ EINGEBEN     = $A560
.EQ INDEX        = $A67A
.EQ ZEIGSTART    = $A68E
.EQ BLOCKVER     = $A3BF
.EQ ZEILLOESCH   = $A4A9
.EQ ZAHLIN       = $A96B
.EQ SGNIN        = $BC49
.EQ FACASC       = $BDDF
.EQ INTOUT       = $BDCD
.EQ BICLEAR      = $E544
.EQ PLOT         = $E50C
.EQ ZEIOUT       = $EA13
.EQ GETPUF       = $E5B4
.EQ BIRECH       = $E6ED
.EQ BILDIN1      = $E63A
.EQ BILDIN2      = $E65D
.EQ AUSGABEB1    = $E6A8
.EQ QUOTETEST    = $E684
.EQ DELETE       = $E75C
.EQ FARBTEST     = $E8CB
.EQ STEUERTEST   = $EC44
.EQ INSERTB      = $E807
.EQ STEUERTEST2  = $EC4F
.EQ BILDRECH     = $E9F0
.EQ LOESCHZEIL   = $E9FF
.EQ ZEILUP       = $E9C8
.EQ PLOTBILD     = $EA1C
.EQ SAVEB        = $E159
.EQ GETPAR       = $E257
.EQ LISTEN       = $ED0C
.EQ SEKLIST      = $EDB9
.EQ IECOUT       = $EDDD
.EQ TESTSTOP     = $FFE1
.EQ LOADB        = $FFD5
.EQ REGISTER     = $FEBC
.EQ TASTSTOP     = $F6BC
.EQ SETIOVEK     = $FD15
.EQ INTINIT      = $FDA3
.EQ IECOPEN      = $F3D5
.EQ SETZEIGER    = $FB8E
.EQ SAVEIN       = $F624
.EQ FILPAR       = $FFBA
.EQ TALK         = $FFB4
.EQ SEKTALK      = $FF96
.EQ IECIN        = $FFA5
.EQ BSOUT        = $FFD2
.EQ IECCLOSE     = $F642
;
;---- BENUTZTE HYPR-ASS ROUTINEN ----
;
.EQ HYOLD        = $1F2F
.EQ HYCOMAND     = $1D53
.EQ HYSTATUS     = $1CC7
.EQ HYRENUM      = $1A3E
.EQ HYDEL        = $193B
.EQ HYLIST1      = $1B82
.EQ HYLIST2      = $1928
.EQ HYLIST3      = $190D
.EQ HYINWART     = $1803
;
;-- MIT HYPRA-ASS IDENTISCHE ADRESSEN --
;
.EQ PAGE1        = $0343
.EQ PAGE2        = $0361
.EQ PAGE3        = $037F
.EQ PAGE4        = $039D
.EQ TABUL        = $0EF4
.EQ DEVICE       = $1F49
;
;----------- FLAGS UND MERKER ------
;
.EQ FLAG         = $02C0
.EQ ZEILSTART    = $02C1
.EQ ZEILEND      = $02C2
.EQ STARTZEIL    = $02C3
.EQ ENDZEIL      = $02C4
.EQ MERKER       = $02C5
.EQ MERKER1      = $02C8
.EQ BLOCKANF     = $02CE
.EQ BLOCKEND     = $02D0
.EQ LISTEND      = $02D3
.EQ BLOCKFARBE   = $02D4
.EQ LISTFARBE    = $02D5
.EQ ZEILE        = $F9
;
;-- TESTET OB HYPRA-ASS ODER EDITOR --
;
DIRECKT  LDA FLAG          
         AND #$80          
         BEQ READYMODE     
         RTS               
READYMODE JMP READY         
;
;--------  INITIALISIERUNG  ---------
;
INITIAL  CLI               
         LDY #$03          
INITLOOP1 LDA VEKTOREN1,Y   
         STA $0300,Y       
         DEY               
         BPL INITLOOP1     
         LDY #$03          
INITLOOP2 LDA VEKTOREN2,Y   
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
SCHRIFT  LDA #$07          
         STA $0286         
         STA LISTFARBE     
BILDGROESSE STY ZEILSTART     
         LDA #$05          
         STA STARTZEIL     
         LDA #$27          
         STA ZEILEND       
         LDA #$18          
         STA ENDZEIL       
         JSR BICLEAR       
KOPFSET  LDY #201          
KOPFLOOP LDA KOPF-1,Y      
         STA $03FF,Y       
         DEY               
         BNE KOPFLOOP      
KOPFEND  JSR BINDNUMLI     
         JSR LASTZEIL      
NOPROG   JSR INDEX         
         JMP NONEWZ        
;
;------- NEUE EINGABEROUTINE --------
;
NEUEINL  LDA $D3           
         STA $CA           
         LDA $D6           
         STA $C9           
         JMP BILDIN        
;
;---------- NEUE NMI-ROUTINE ---------
;
NMI      PHA               
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
NOSTOP2  JMP REGISTER      
;
;- TABELLE BEFEHLSZEICHEN UND ADRESSEN -
;
SONDER   .TX "����������"
         .TX "	_"       
BEFNAME  .TX "@BGIKLMNOSTX"
INITNAME .TX "LS@MB"       
;
FUNKADR  .WO INDOWN,INCRSRUP
         .WO INHOME,INCLEAR
         .WO F1,F2,F3,F4   
         .WO F5,F6,F7,F8   
         .WO CTRLA,CTRLB,CTRLC
         .WO CTRLD,CTRLE,CTRLI
         .WO CTRLK,CTRLL,CTRLR
         .WO KOMMANDO      
BEFADR   .WO COMAND,BLOSALO,GOTO
         .WO FILES,STATUS,LOAD
         .WO MERGE,NEW,OLD,SAVE
         .WO TABULATOR,RESET
;
VEKTOREN1 .WO DATENEND1,INWART
VEKTOREN2 .WO NEUEINL,AUSGEBEN
TABELLE5 .WO $E38B,$179D   
;
;------- TEXTE DER MELDUNGEN -------
;
APPEND   .TX "SPEICHERENDE: "
         .TX "APPEND-FILE ANLEGEN"
         .BY $00           
TEXT1    .TX "KOMMANDO: "  
         .BY $00           
TEXT2    .TX "STATUS..: "  
         .BY $00           
TEXT3    .TX "BLOCKFEHLER: "
         .TX "BLOCK ZU LANG"
         .BY $00           
ANFANG   .BY $0C,$22,$30,$3A
         .BY 19,$22,$00,$3A
         .BY $00,19,$30,$3A
         .BY $0D,$22,$30,$3A
         .BY $02,$0C,$22,$3A
START    .BY $00,$04,$08,$0C,$10
;
BLOCKLAENGE .BY $00,$00       
;
;--- DATEN IN KOPFZEILE AUSGEBEN ---
;
DATENOUT LDA #<($0407+40)  
         LDY #>($0407+40)  
         JSR SETBILD       
         LDA $FA           
         LDX $F9           
         LDY #$06          
         JSR DATENRECH     
         LDA #<($0416+40)  
         LDY #>($0416+40)  
         JSR SETBILD       
         LDA #$00          
         LDX $D3           
         LDY #$03          
         JSR DATENRECH     
         LDA #<($0400+73)  
         LDY #>($0400+73)  
         JSR SETBILD       
         SEC               
         LDA $37           
         SBC $2D           
         TAX               
         LDA $38           
         SBC $2E           
         LDY #$05          
         JMP DATENRECH     
;
;------ EINGABEWARTESCHLEIFE ------
;
TASTWAIT JSR AUSGEBEN      
TASTWAIT1 JSR DATENOUT      
         LDY $D3           
         LDA ($D1),Y       
         STA $CE           
         EOR #$80          
         PHA               
         LDA ($F3),Y       
         STA $0287         
         PLA               
         LDX $0286         
         JSR ZEIOUT        
TASTLOOP LDA $C6           
         BEQ TASTLOOP      
         JSR BLOCKTEST     
         SEI               
         LDA $CE           
         LDX $0287         
         JSR ZEIOUT        
         JSR GETPUF        
         PHA               
         CMP #"_"          
         BNE NOKOMMAND1    
         LDA FLAG          
         PHA               
         AND #$04          
         BNE NOKOMMAND     
         PLA               
         PHA               
         AND #$02          
         BEQ NOKOMMAND     
         PLA               
         AND #$F9          
         STA FLAG          
         JSR NOBEF         
         JSR RETURNIN      
         JMP NOPROG        
;
NOKOMMAND PLA               
NOKOMMAND1 LDA FLAG          
         AND #$06          
         BNE NOFUNKTION    
         LDA $D4           
         BNE NOFUNKTION    
         LDA $D8           
         BNE NOFUNKTION    
         PLA               
         PHA               
CTRLTEST LDX #$15          
TASTTESTL CMP SONDER,X      
         BEQ SONDFOUND     
         DEX               
         BPL TASTTESTL     
NOFUNKTION PLA               
         CMP #$0D          
         BNE TASTWAIT      
         RTS               
;
SONDFOUND PLA               
         TXA               
         ASL               
         TAX               
         LDA FUNKADR,X     
         STA JUMP1+1       
         LDA FUNKADR+1,X   
         STA JUMP1+2       
JUMP1    JSR $B248         
         JMP TASTWAIT1     
;
TASTIN   JSR TASTWAIT1     
INTAST   LDY ZEILEND       
         STY $D0           
NONULL   LDA ($D1),Y       
         CMP #$20          
         BNE NOSPC         
         DEY               
         CPY ZEILSTART     
         BPL NONULL        
         INY               
         STY $D3           
         BEQ TASTIN        
NOSPC    LDA FLAG          
         AND #$D9          
         STA FLAG          
         INY               
BILDININ STY $D0           
         STY $C8           
         LDY #$00          
         STY $0292         
         STY $D3           
         STY $D4           
         LDA $C9           
         BMI MARKEA1       
         LDX $D6           
         JSR BIRECH        
         CPX $C9           
         BNE MARKEA1       
         LDA $CA           
         STA $D3           
         CMP $C8           
         BCC MARKEA1       
         BCS MARKEA2       
;
BILDIN   TYA               
         PHA               
         TXA               
         PHA               
         LDA $D0           
         BEQ TASTIN        
MARKEA1  JMP BILDIN1       
MARKEA2  JMP BILDIN2       
;
;------ AUSGABE AUF BILDSCHIRM -------
;
AUSGABE  ORA #$40          
AUSGABE1 LDX $C7           
         BEQ NOREVERS      
AUSGABE2 ORA #$80          
NOREVERS LDX $D8           
         BEQ NOINSERT      
         DEC $D8           
NOINSERT LDX $0286         
         JSR ZEIOUT        
         CPY ZEILEND       
         BEQ AUSGABE3      
         INC $D3           
AUSGABE3 JMP AUSGABEB1     
;
AUSGEBEN PHA               
         STA $D7           
         TXA               
         PHA               
         TYA               
         PHA               
         LDA #$00          
         STA $D0           
         LDY $D3           
         LDA $D7           
         BPL KLEINER       
         JMP GROESSER      
KLEINER  CMP #$0D          
         BNE NORETURN      
         JSR RETURN        
         JMP AUSGABE3      
NORETURN CMP #$20          
         BCC MARKE1        
         CMP #$60          
         BCC MARKE2        
         AND #$DF          
         BNE MARKE3        
MARKE2   AND #$3F          
MARKE3   JSR QUOTETEST     
         JMP AUSGABE1      
MARKE1   LDX $D8           
         BEQ MARKE4        
         JMP AUSGABE2      
MARKE4   CMP #$14          
         BNE MARKE5        
         CPY ZEILSTART     
         BEQ NODEL         
         LDA ZEILEND       
         STA $D5           
         JMP DELETE        
MARKE5   LDX $D4           
         BEQ MARKE6        
         JMP AUSGABE2      
MARKE6   CMP #$12          
         BNE MARKE7        
         STA $C7           
MARKE7   CMP #$13          
         BNE MARKE8        
         JSR HOME          
NODEL    JMP AUSGABE3      
MARKE8   CMP #$1D          
         BNE MARKE9        
         CPY ZEILEND       
         BCS MARKE9A       
         INC $D3           
         JMP AUSGABE3      
MARKE9A  LDA FLAG          
         AND #$06          
         BNE MARKE9B       
         LDY #$00          
         STY $D3           
         JSR INDOWN        
MARKE9B  JMP AUSGABE3      
MARKE9   CMP #$11          
         BNE MARKE10       
         JSR DOWN          
         JMP AUSGABE3      
MARKE10  JSR FARBTEST      
         JMP STEUERTEST    
GROESSER AND #$7F          
         CMP #$7F          
         BNE MARKE11       
         LDA #$5E          
MARKE11  CMP #$20          
         BCC MARKE12       
         JMP AUSGABE       
MARKE12  CMP #$0D          
         BNE MARKE13       
         JSR RETURN        
         JMP AUSGABE3      
MARKE13  LDX $D4           
         BNE MARKE14       
         CMP #$14          
         BNE MARKE15       
         LDY ZEILEND       
         LDA ($D1),Y       
         CMP #$20          
         BNE MARKE16       
         CPY $D3           
         BEQ MARKE16       
         JMP INSERTB       
MARKE16  JMP AUSGABE3      
MARKE15  LDX $D8           
         BEQ MARKE17       
MARKE14  ORA #$40          
         JMP AUSGABE2      
MARKE17  CMP #$11          
         BNE MARKE18       
         JSR CRSRUP        
         JMP AUSGABE3      
MARKE18  CMP #$12          
         BNE MARKE19       
         LDA #$00          
         STA $C7           
MARKE19  CMP #$1D          
         BNE MARKE20       
         CPY ZEILSTART     
         BEQ MARKE20A      
         DEC $D3           
         JMP AUSGABE3      
MARKE20A LDA FLAG          
         AND #$06          
         BNE MARKE20B      
         LDY #$27          
         STY $D3           
         JSR INCRSRUP      
MARKE20B JMP AUSGABE3      
MARKE20  CMP #$13          
         BNE MARKE21       
         JSR CLEAR         
         JMP AUSGABE3      
MARKE21  ORA #$80          
         JSR FARBTEST      
         JMP STEUERTEST2   
;
;--- CURSOR-HOME FUNKTIONEN ---
;
INHOME   JSR CURPOS        
         LDA FLAG          
         PHA               
         AND #$01          
         BEQ NOFLAG        
         ORA #$10          
         STA FLAG          
         JSR SEITLISTIN    
         PLA               
         STA FLAG          
         JMP LIST          
NOFLAG   PLA               
STARTCUR LDX STARTZEIL     
         LDY ZEILSTART     
         JMP PLOT          
;
HOME     LDA FLAG          
         AND #$06          
         BNE NOCRSR        
         JMP STARTCUR      
;
;----- CLEAR-HOME FUNKTIONEN -----
;
INCLEAR  JSR NULLZEILE     
         JMP LISTLAST      
;
CLEAR    LDA FLAG          
         AND #$06          
         BNE NOCRSR        
         JSR SCRCLEAR      
         JMP HOME          
;
;------ CURSOR DOWN FUNKTIONEN ------
;
INDOWN   JSR ZEILINC       
         BCS NOINUP        
         JSR DOWN          
         BCC NOINUP        
         JSR LIST          
         JMP NOINUP        
;
DOWN     LDA FLAG          
         AND #$06          
         BNE NOCRSR        
         LDX $D6           
         CPX ENDZEIL       
         BCC NOSCRDWN      
         TXA               
         PHA               
         JSR SCRDWN        
         PLA               
         TAX               
         DEX               
         SEC               
NOSCRDWN INX               
NOSCRIND LDY $D3           
         JMP PLOT          
;
NOCRSR   SEC               
         RTS               
;
;------ CURSOR UP FUNKTIONEN ------
;
INCRSRUP LDA FLAG          
         TAY               
         AND #$01          
         BEQ NOBLOCK       
         TYA               
         ORA #$10          
         STA FLAG          
         JSR LIST          
         LDA FLAG          
         AND #$EF          
         STA FLAG          
NOBLOCK  JSR ZEILDEC       
         BCS NOINUP        
         JSR CRSRUP        
         BCS NOINUP        
         JMP LIST          
;
NOINUP   LDA FLAG          
         AND #$01          
         BEQ NOINUP1       
         JSR LIST          
NOINUP1  SEC               
         RTS               
;
CRSRUP   LDA FLAG          
         AND #$06          
         BNE NOCRSR        
CRSRUPIN LDX $D6           
         CPX #$06          
         BCS NOSCRUP       
         TXA               
         PHA               
         JSR SCRUP         
         PLA               
         TAX               
         CLC               
         INX               
NOSCRUP  DEX               
         JMP NOSCRIND      
;
;-------- RETURN -------------
;
RETURN   LDY ZEILSTART     
         STY $D3           
RETURNIN LDY #$00          
         STY $D8           
         STY $C7           
         STY $D4           
         RTS               
;
;-- ZEILEN BINDEN UND SEITE LISTEN --
;
BINDNUMLI JSR ZEILBIND      
         JSR RENUMBER      
         JMP SEITLIST      
;
;----   ZEILE AUF NULL SETZEN   ----
;
NULLZEILE LDA #$00          
         TAY               
         JMP SETIN         
;
;-- CURSOR IN KOMMANDOZEILE SETZEN --
;
COMSTART LDX #$03          
         LDY #$01          
         JMP PLOT          
;
;- EINSPRG FUER SUBTRAKTION VON ZEILE -
;
SBC00    STA ZEILE         
         BCS NOSUB2        
         DEC ZEILE+1       
NOSUB2   RTS               
;
;-- EINSPRG FUER ADDITION VON ZEILE --
;
RECHNEN1 LDA MERKER1       
         SEC               
         SBC #$05          
RECHIN   CLC               
         ADC ZEILE         
         STA ZEILE         
         BCC NOZEIL7       
         INC ZEILE+1       
NOZEIL7  RTS               
;
;-- DATEN IN DER KOPFZEILE AUSGEBEN --
;
DATENRECH STY $02           
         STA $62           
         STX $63           
         LDX #$90          
         SEC               
         JSR SGNIN         
         JSR FACASC        
         LDX #$00          
DATLL    LDA $0100,X       
         BEQ DATENEND      
         INX               
         BNE DATLL         
DATENEND DEX               
         LDY $02           
OUTL     LDA $0100,X       
         ORA #$80          
         STA ($F7),Y       
         DEY               
         DEX               
         BPL OUTL          
         CPY #$00          
         BEQ DATENEND1     
         LDA #$A0          
FUELLOOP STA ($F7),Y       
         DEY               
         BNE FUELLOOP      
DATENEND1 RTS               
;
;-- AKTUELLE CURSORPOSITION MERKEN --
;
CURRETT  LDX $D6           
         LDY $D3           
         STX MERKER1       
         STY MERKER1+1     
;
;--- CURSORPOSITION ZURUECKHOLEN ---
;
CURRET1  LDX MERKER1       
         LDY MERKER1+1     
         JMP PLOT          
;
CURRET   JSR RECHNEN1      
         JMP CURRET1       
;
;--------- SCROLLEN ABWAERTS --------
;
SCRDWN   LDX STARTZEIL     
SCRDWNIN CPX ENDZEIL       
         BEQ NOSCRDWNL1    
SCRDWNL  JSR BILDRECH      
         INX               
         LDA $ECF0,X       
         STA $AC           
         LDA $D9,X         
         JSR ZEILUP        
         CPX ENDZEIL       
         BNE SCRDWNL       
NOSCRDWNL1 JSR LOESCHZEIL    
NOSCRDWNL LDX ENDZEIL       
         JMP NOSCRIND      
;
;--------- SCROLLEN AUFWAERTS --------
;
SCRUP    LDX ENDZEIL       
         CPX STARTZEIL     
         BEQ NOSCRUPL      
SCRUPL   JSR BILDRECH      
         DEX               
         LDA $ECF0,X       
         STA $AC           
         LDA $D9,X         
         JSR ZEILUP        
         CPX STARTZEIL     
         BNE SCRUPL        
NOSCRUPL JSR LOESCHZEIL    
         LDX STARTZEIL     
         JMP NOSCRIND      
;
;- TEST OB CRSR IN,VOR ODER NACH BLOCK -
;
BLOCKTEST LDA ZEILE+1       
         CMP BLOCKANF+1    
         BCC VORBLOCK1     
         BNE ENDETEST      
         LDA ZEILE         
         CMP BLOCKANF      
         BCC VORBLOCK1     
ENDETEST SEC               
         LDA BLOCKEND      
         SBC ZEILE         
         LDA BLOCKEND+1    
         SBC ZEILE+1       
         BMI NACHBLOCK     
         BCS ISTBLOCK      
         SEC               
         RTS               
NACHBLOCK LDA FLAG          
         AND #$F7          
         STA FLAG          
         RTS               
ISTBLOCK LDA FLAG          
         ORA #$08          
         STA FLAG          
         LSR               
         CLC               
         RTS               
VORBLOCK1 LDA FLAG          
         AND #$F6          
         STA FLAG          
         LSR               
         SEC               
         RTS               
;
;----- CURSORPOSITION BERECHNEN -----
;
CURPOS   LDA $D6           
         SEC               
         SBC STARTZEIL     
         STA $02           
         LDA ZEILE         
         SEC               
         SBC $02           
         JMP SBC00         
;
;------- BILDSCHIRM LOESCHEN -------
;
SCRCLEAR LDX ENDZEIL       
SCRCLRL  JSR LOESCHZEIL    
         DEX               
         CPX STARTZEIL     
         BNE SCRCLRL       
         JSR LOESCHZEIL    
         RTS               
;
;--- PRUEFT AUF NAECHSTE TEXTZEILE ---
;
NEXTZEIL LDY #$01          
         LDA ($5F),Y       
         BEQ SETCARRY      
         JSR HYLIST2       
         CLC               
         RTS               
;
;---- ERHOEHT UND PRUEFT ZEILE -----
;
ZEILINC  LDY #$01          
         LDA ($5F),Y       
         BNE NOSUCHEN      
         JSR SUCHZEIL      
         BCC SETCARRY      
NOSUCHEN JSR NEXTZEIL      
         BCS SETCARRY      
ZEILINCIN INC ZEILE         
         BNE NOZEI1        
         INC ZEILE+1       
NOZEI1   CLC               
         RTS               
;
;----- VERMINDERT UND PRUEFT ZEILE ----
;
ZEILDEC  LDX ZEILE         
         BNE DECZEIL       
         LDY ZEILE+1       
         BEQ SETCARRY      
         DEC ZEILE+1       
DECZEIL  DEC ZEILE         
         CLC               
         .BY $24           
SETCARRY SEC               
NOINC4   RTS               
;
;- POSITIONIERT CURSOR IN LETZTE ZEILE -
;
LASTZEIL JSR CURPOS        
         LDY ZEILE+1       
         LDA ZEILE         
         CLC               
         ADC #19           
         BCC NOINC2        
         INY               
NOINC2   JSR SET14         
         JSR ZEILSUCH      
         BCC NOINC4        
         LDA $14           
         LDY $15           
         JSR SETIN         
         LDX ENDZEIL       
         LDY ZEILSTART     
         JMP PLOT          
;
;-- SETZT AKTUELLE ZEILE NACH $14/$15 --
;
SETZEILE LDA ZEILE         
         LDY ZEILE+1       
SET14    STA $14           
         STY $15           
         RTS               
;
;------- LOESCH CURSORZEILE -------
;
ZEILCLR  LDX $D6           
CLEARIN  LDY ZEILEND       
         JSR PLOT          
ZEICLRL  LDA #$20          
         LDX $0286         
         JSR PLOTBILD      
         DEY               
         STY $D3           
         CPY ZEILSTART     
         BPL ZEICLRL       
         INC $D3           
         RTS               
;
;--- SUCHT EINE ZEILE AUS QUELLTEXT --
;
SUCHZEIL JSR SETZEILE      
         JMP ZEILSUCH      
;
;------- AENDERT VEKTOREN --------
;
NEWVEKTOR LDA #<(VEKTOR)    
         LDY #>(VEKTOR)    
VEKTORIN STA $0302         
         STY $0303         
VEKTOR   RTS               
;
OLDVEKTOR LDA #<(INWART)    
         LDY #>(INWART)    
         JMP VEKTORIN      
;
;----- NUMMERIERT QUELLTEXT NEU -----
;
RENUMBER LDA $2B           
         LDY $2C           
         STA $5F           
         STY $60           
         LDA #$00          
         TAX               
         STA $FE           
RENUMIN  STA $033D         
         STX $033C         
         LDA #$01          
         STA $0340         
         LDA #$FF          
         STA $14           
TEST     STA $15           
         JSR NEWVEKTOR     
         JSR HYRENUM       
         JMP OLDVEKTOR     
;
;---- LISTROUTINE ALLGEMEIN ------
;
LIST     JSR SUCHZEIL      
         BCC NOLIST1       
LISTIN   LDA $D3           
         STA MERKER1+4     
         LDA LISTFARBE     
         STA $0286         
         JSR BLOCKTEST     
         LDA FLAG          
         AND #$09          
         BEQ NOAENDERN     
         LDA FLAG          
         AND #$01          
         BEQ NODEFUP       
         LDA FLAG          
         AND #$10          
         BNE NOAENDERN     
NODEFUP  LDA BLOCKFARBE    
         STA $0286         
NOAENDERN LDX #$00          
         STX $D3           
         JSR HYLIST1       
NOLIST   JSR HYLIST2       
         LDA MERKER1+4     
         STA $D3           
         LDA #$00          
         STA $D4           
NOLIST1  RTS               
;
;------- LISTET BILDSCHIRMSEITE ------
;
SEITLIST JSR SCRCLEAR      
SEITLISTIN JSR STARTCUR      
         JSR SUCHZEIL      
         BCC NOLIST2       
         LDA $14           
         LDY $15           
         CLC               
         ADC #$13          
         BCC NOADDLI       
         INY               
NOADDLI  JSR SET14         
LISTLOOP JSR LISTIN        
         JSR HYLIST3       
         BCS NOLIST2       
         LDX $D6           
         INX               
         LDY ZEILSTART     
         JSR PLOT          
         JSR ZEILINCIN     
         JMP LISTLOOP      
NOLIST2  JSR CURPOS        
         JMP STARTCUR      
;
;- LETZTE BILDSCHIRMZEILE BEI CTRL-D -
;
LISTZEIL LDY ZEILE+1       
         LDA ENDZEIL       
         SEC               
         SBC MERKER+2      
         CLC               
         ADC ZEILE         
         ADC #$01          
         BCC NOINCZEI      
         INY               
NOINCZEI JSR SET14         
         JSR ZEILSUCH      
         BCC NOFOUND       
         JSR SETIN1        
         LDA $14           
         STA ZEILE         
         LDY $15           
         STY ZEILE+1       
         JSR LISTIN        
         JSR BLOCKEND1     
NOFOUND  LDX MERKER+2      
         LDY ZEILSTART     
         JMP PLOT          
;
;--- ROUTINE FUER PROGRAMMEINGABE ----
;
INWART   JSR ZEILCLR       
         JSR LISTIN        
         JSR INDOWN        
NONEWZ   JSR EINGEBEN      
         STX $7A           
         STY $7B           
         JSR CHRGET        
         TAX               
         BEQ INWART        
         LDA $2D           
         LDY $2E           
NOINY5   CPY #$9F          
         BCC INMEM         
         CMP #$90          
         BCC INMEM         
         JSR CURRETT       
         JSR COMSTART      
         LDA #<(APPEND)    
         LDY #>(APPEND)    
         JSR SETSTRING     
         LDA #$00          
         STA $0200         
         JSR CURRET1       
         JMP KOPFEND       
;
INMEM    JSR SETZEILE      
         LDX #$00          
         JMP HYINWART      
;
;-- CTRL-FUNKTIONEN (CTRLA - CTRLR) --
;
CTRLA    LDA ZEILE         
         LDY ZEILE+1       
         STA BLOCKANF      
         STA BLOCKEND      
         STY BLOCKANF+1    
         STY BLOCKEND+1    
         JSR SETBILD       
         LDA FLAG          
         PHA               
         ORA #$11          
         JSR SEITOKLI      
         PLA               
         ORA #$01          
         STA FLAG          
         JMP LIST          
;
NOINSERTCC JMP BLOCKNOK      
;
CTRLB    JSR CURRETT       
         JSR SUCHZEIL      
         LDA BLOCKLAENGE   
         ORA BLOCKLAENGE+1 
         BNE BLOCKOK1      
         RTS               
BLOCKOK1 CLC               
         LDA $2D           
         STA $5A           
         ADC BLOCKLAENGE   
         STA $58           
         TAX               
         LDA $2E           
         STA $5B           
         ADC BLOCKLAENGE+1 
         CMP #$9F          
         BCC INSERT        
         CPX #$90          
         BCS NOINSERTCC    
INSERT   STX $2D           
         STA $2E           
         STA $59           
         INC $5A           
         BNE NOADD2        
         INC $5B           
NOADD2   LDA $5F           
         PHA               
         LDA $60           
         PHA               
         JSR BLOCKVER      
         PLA               
         STA $60           
         PLA               
         STA $5F           
         LDY #$04          
         STY $22           
         LDA #$E0          
         STA $23           
         SEI               
         LDA #$35          
         STA $01           
         LDY BLOCKLAENGE   
         LDX BLOCKLAENGE+1 
         INX               
CTRLBLOOP1 TYA               
         PHA               
         LDY #$00          
         LDA ($22),Y       
         STA ($5F),Y       
         INC $5F           
         BNE NOADD3        
         INC $60           
NOADD3   INC $22           
         BNE NOADD4        
         INC $23           
NOADD4   PLA               
         TAY               
         DEY               
         BNE CTRLBLOOP1    
         DEX               
         BNE CTRLBLOOP1    
         SEC               
         LDA $E002         
         SBC $E000         
         PHA               
         LDA $E003         
         SBC $E001         
         TAY               
         PLA               
         CLC               
         ADC ZEILE         
         STA BLOCKEND      
         TYA               
         ADC ZEILE+1       
         STA BLOCKEND+1    
         LDA ZEILE         
         STA BLOCKANF      
         LDA ZEILE+1       
         STA BLOCKANF+1    
         LDA #$37          
         STA $01           
         CLI               
         JSR CURPOS        
         JSR BINDNUMLI     
         JMP CURRET        
;
CTRLC    LDA $91           
         AND #$80          
         BEQ ISTSTOP       
NOSTOP   LDA #$20          
         STA $0400+158     
         LDA BLOCKEND      
         LDY BLOCKEND+1    
         STA $E002         
         STY $E003         
         JSR SET14         
         JSR ZEILSUCH      
         BCC BLOCKNOK      
         LDY #$01          
         LDA ($5F),Y       
         TAX               
         DEY               
         LDA ($5F),Y       
         TAY               
         INY               
         BNE NOADD1        
         INX               
NOADD1   STX $5B           
         STY $5A           
         LDA BLOCKANF      
         LDY BLOCKANF+1    
         STA $E000         
         STY $E001         
         JSR SET14         
         JSR ZEILSUCH      
         SEC               
         LDA $5A           
         SBC $5F           
         STA BLOCKLAENGE   
         TAX               
         LDA $5B           
         SBC $60           
         STA BLOCKLAENGE+1 
         TAY               
         CLC               
         TXA               
         ADC #$04          
         STA $58           
         TYA               
         ADC #$E0          
         BPL BLOCKNOK      
         STA $59           
         JSR BLOCKVER      
         LDA #42           
         STA $0400+158     
         CLC               
ISTSTOP  RTS               
;
BLOCKNOK JSR CURRETT       
         JSR COMSTART      
         LDA $0286         
         PHA               
         LDA LISTFARBE     
         STA $0286         
         LDA #<(TEXT3)     
         LDY #>(TEXT3)     
         JSR SETSTRING     
         PLA               
         STA $0286         
         JSR CURRET1       
         SEC               
         RTS               
;
CTRLD    LDX $D6           
         STX MERKER+2      
         JSR SCRDWNIN      
         JSR LISTZEIL      
         JSR SUCHZEIL      
         BCS NOFOUNDOK     
         JMP NOFOUND       
NOFOUNDOK LDA #<(ZURUECK)   
         LDY #>(ZURUECK)   
         JSR VEKTORIN      
         LDA #$00          
         STA $0200         
         JMP ZEILLOESCH    
ZURUECK  JSR OLDVEKTOR     
         JSR BLOCKTEST     
         BMI NODECREM      
         BCC ENDDECR       
         LDY BLOCKANF      
         BNE NOBLOCKDEC1   
         DEC BLOCKANF+1    
NOBLOCKDEC1 DEC BLOCKANF      
ENDDECR  LDY BLOCKEND      
         BNE NODECBL       
         DEC BLOCKEND+1    
NODECBL  DEC BLOCKEND      
NODECREM JSR RENUMBER      
         JMP NONEWZ        
;
CTRLE    JSR BLOCKTEST     
         BCC NOTEST6       
         RTS               
NOTEST6  JSR SETIN1        
         STA BLOCKEND      
         STY BLOCKEND+1    
         LDA FLAG          
         AND #$D6          
SEITOKLI STA FLAG          
         JSR CURRETT       
         JSR CURPOS        
         JSR SEITLISTIN    
         JSR CURRET1       
         JMP BLOCKEND1     
NOBLOCKEND RTS               
;
CTRLI    LDA FLAG          
         ORA #$06          
         STA FLAG          
         LDA STARTZEIL     
         PHA               
         LDX $D6           
         STX STARTZEIL     
         JSR SCRUP         
         PLA               
         STA STARTZEIL     
         JSR SUCHZEIL      
         BCC ENDINSERT     
RENLOOP1 LDY #$01          
         LDA ($5F),Y       
         BEQ ENDINSERT     
         LDA #$00          
         STA $FE           
         LDY #$02          
         LDA ($5F),Y       
         TAX               
         INY               
         LDA ($5F),Y       
         INX               
         BNE NOT2INC       
         CLC               
         ADC #$01          
NOT2INC  JSR RENUMIN       
         JSR BLOCKTEST     
         BMI ENDINSERT     
         BCC INBLOCK       
         INC BLOCKANF      
         BNE INBLOCK       
         INC BLOCKANF+1    
INBLOCK  INC BLOCKEND      
         BNE ENDINSERT     
         INC BLOCKEND+1    
ENDINSERT LDX $D6           
         LDY ZEILSTART     
         JMP PLOT          
;
CTRLK    LDY #$27          
TABTEST  LDA ($D1),Y       
         CMP #$3B          
         BEQ FOUND55       
         DEY               
         CPY TABUL+1       
         BPL TABTEST       
         RTS               
FOUND55  LDA #$20          
DEL1LOOP STA ($D1),Y       
         INY               
         CPY #$28          
         BCC DEL1LOOP      
         LDA #$0D          
         STA $0277         
         LDA #$01          
         STA $C6           
;
NOINSCTR RTS               
;
CTRLL    JSR CURRETT       
         JSR CURPOS        
         LDA BLOCKANF      
         LDY BLOCKANF+1    
         JSR SET14         
         JSR ZEILSUCH      
         LDA BLOCKEND      
         LDY BLOCKEND+1    
         JSR SET14         
         JSR NEWVEKTOR     
         JSR HYDEL         
         JSR OLDVEKTOR     
         JSR BLOCKTEST     
         BMI NACHBLOCK5    
         BCC NACHBLOCK5    
EINSPRUNGX LDY #$03          
         LDA #$00          
BLOCKLOESCH STA BLOCKANF,Y    
         DEY               
         BPL BLOCKLOESCH   
         JSR BINDNUMLI     
         JMP CURRET        
;
NACHBLOCK5 SEC               
         LDA BLOCKEND      
         SBC BLOCKANF      
         STA $02           
         LDA BLOCKEND+1    
         SBC BLOCKANF+1    
         TAY               
         CLC               
         LDA ZEILE         
         SBC $02           
         TAX               
         STY $02           
         LDA ZEILE+1       
         SBC $02           
         TAY               
         TXA               
         JSR SETIN         
         JMP EINSPRUNGX    
;
CTRLR    LDY #$27          
         LDA #$20          
LOESCHLOOP STA ($D1),Y       
         DEY               
         CPY $D3           
         BPL LOESCHLOOP    
NOF37    RTS               
;
;---- FUNKTIONSTATSTEN (F1 - F8) ----
;
F1       JSR CURPOS        
         LDA ZEILE         
         SEC               
         SBC #$14          
         JSR SBC00         
         JSR SUCHZEIL      
         BCC NOF1          
         JMP SEITLIST      
NOF1     LDA #$14          
         .BY $2C           
NOF2     LDA #40           
         JSR RECHIN        
         JMP SEITLIST      
;
F2       JSR CURPOS        
         LDA ZEILE         
         SEC               
         SBC #40           
         JSR SBC00         
         JSR SUCHZEIL      
         BCC NOF2          
         JMP SEITLIST      
;
F3       JSR CURPOS        
         LDA ZEILE         
         LDY ZEILE+1       
         CLC               
         ADC #$14          
         BCC NOINCF3       
         INY               
NOINCF3  JSR SET14         
NOINC3   JSR ZEILSUCH      
         BCC NOF37         
F3IN     LDA $14           
         LDY $15           
         JSR SETIN         
LISTLAST JSR SEITLIST      
         JMP LASTZEIL      
;
F4       JSR CURPOS        
         CLC               
         LDA ZEILE         
         LDY ZEILE+1       
         ADC #40           
         BCC NOADDF7       
         INY               
NOADDF7  JSR SET14         
         JSR ZEILSUCH      
         BCC NOF37         
         JMP F3IN          
;
F5       LDX $D6           
         LDY $D3           
         CPY TABUL         
         BCS TABRETURN     
         LDY TABUL         
         JMP PLOT          
TABRETURN LDY ZEILSTART     
         JMP PLOT          
;
F6       INC $D020         
         RTS               
;
F7       INC $0286         
         INC LISTFARBE     
         INC BLOCKFARBE    
         JSR CURRETT       
         JSR CURPOS        
         JSR SEITLISTIN    
         JMP CURRET        
;
F8       INC $D021         
NOKOMM   RTS               
;
;------- KOMMANDOEINGABE -----------
;
KOMMANDO LDA LISTFARBE     
         STA $0286         
         LDA #$00          
         STA $9D           
         JSR CURRETT       
         LDA ZEILEND       
         STA MERKER1+2     
         LDA ZEILSTART     
         STA MERKER1+3     
         JSR CURPOS        
         LDA #$0B          
         STA ZEILSTART     
         LDA #$25          
         STA ZEILEND       
KOMMLOOP JSR COMSTART      
         LDA #<(TEXT1)     
         LDY #>(TEXT1)     
         JSR SETSTRING     
         LDA FLAG          
         AND #$20          
         BNE NOCLEAR       
         JSR ZEILCLR       
NOCLEAR  LDA FLAG          
         ORA #$02          
         STA FLAG          
KOMMIN1  JSR EINGEBEN      
         STX $7A           
         STY $7B           
         JSR CHRGET        
         BEQ KOMMLOOP      
         LDX #$0B          
BEFTEST  CMP BEFNAME,X     
         BEQ BEFFOUND      
         DEX               
         BPL BEFTEST       
         JSR ZEILCLR       
         JMP KOMMLOOP      
;
BEFFOUND TXA               
         ASL               
         TAX               
         LDA BEFADR,X      
         STA JUMP+1        
         LDA BEFADR+1,X    
         STA JUMP+2        
JUMP     JSR $B248         
NOBEF    LDA MERKER1+2     
         STA ZEILEND       
         LDA MERKER1+3     
         STA ZEILSTART     
         JSR CURRET        
         LDA FLAG          
         AND #$DF          
         STA FLAG          
         LDA #$80          
         STA $9D           
NOZEIL8  RTS               
;
;--------- GOTO-KOMMANDOS ------------
;
GOTO     JSR CHRGET        
         BEQ NOZEIL8       
         BCS GOTOBLOCK     
         JSR ZAHLIN        
         JSR ZEILSUCH      
         BCC NOZEIL8       
         LDA $14           
         LDY $15           
         JMP GOTOBLOCKIN   
;
GOTOBLOCK CMP #"B"          
         BNE GLABEL        
         LDA BLOCKANF      
         LDY BLOCKANF+1    
GOTOBLOCKIN JSR SETIN         
EINSPRUNG3 LDX #$05          
         STX MERKER1       
         JMP SEITLIST      
;
GLABEL   JSR SETIN1        
         JSR NULLZEILE     
         JSR STARTCUR      
         JSR SUCHZEIL      
         JSR CHRGET        
TESTLOOP1 LDY #$01          
         LDA ($5F),Y       
         BEQ BLOCKEND1     
         LDA ($5F),Y       
         PHA               
         DEY               
         LDA ($5F),Y       
         PHA               
         LDA $5F           
         CLC               
         ADC #$04          
         STA $5F           
         BCC NOSUBINC      
         INC $60           
NOSUBINC LDY #$00          
         LDA ($7A),Y       
         CMP #"?"          
         BEQ LFOUND1       
         CMP ($5F),Y       
         BEQ LFOUND1       
NOFOUND5 JSR ZEILINCIN     
NOINCZ1  PLA               
         STA $5F           
         PLA               
         STA $60           
         JMP TESTLOOP1     
LFOUND1  INY               
         LDA ($7A),Y       
         BEQ GOTOEND       
         CMP #$22          
         BEQ GOTOEND       
         CMP #"?"          
         BEQ LFOUND1       
         CMP #"*"          
         BEQ JOKER1        
         CMP ($5F),Y       
         BNE NOFOUND5      
         BEQ LFOUND1       
         INY               
GOTOEND  LDA ($5F),Y       
         BEQ JOKER1        
         CMP #$20          
         BNE NOFOUND5      
JOKER1   PLA               
         PLA               
         JMP EINSPRUNG3    
;
;----- SETZT VERSCHIEDENE WERTE ------
;
BLOCKEND1 LDA $F7           
         LDY $F8           
SETIN    STA ZEILE         
         STY ZEILE+1       
SETIN1   LDA ZEILE         
         LDY ZEILE+1       
SETBILD  STA $F7           
         STY $F8           
         RTS               
;
;---------- KOMMANDO OLD -----------
;
OLD      JSR RENUMBER      
         JSR NEWVEKTOR     
         JSR HYOLD         
         JSR OLDVEKTOR     
         JSR NULLZEILE     
         JMP SEITLIST      
;
;---------- TABULATOREN SETZEN -----
;
TABULATOR JSR HOLZAHL       
         STX MERKER        
         JSR CHRGOT        
         CMP #$2C          
         BNE TABENDE       
         JSR HOLZAHL       
         CPX #35           
         BCS TABENDE       
         LDY MERKER        
         CPY #$02          
         BCS TABENDE       
         TXA               
         STA TABUL,Y       
TABENDE  JMP SEITLIST      
;
;---------- KOMMANDO NEW -----------
;
NEW      JSR NULLZEILE     
         STA ($2B),Y       
         INY               
         STA ($2B),Y       
         LDA $2B           
         CLC               
         ADC #$02          
         STA $2D           
         LDA $2C           
         ADC #$00          
         STA $2E           
         JSR SCRCLEAR      
         LDA $2B           
         STA $5F           
         LDA $2C           
         STA $60           
         LDX #$05          
         STX MERKER1       
         JMP ZEIGSTART     
;
;- KOMMANDO 'X' (ZURUEK IN HYPRA-ASS) -
;
RESET    JSR NOBEF         
         JSR BICLEAR       
         LDY #$04          
RESETLOOP LDA TABELLE5-1,Y  
         STA $02FF,Y       
         DEY               
         BNE RESETLOOP     
         STY $02           
         STY FLAG          
         JSR SETIOVEK      
         JSR INTINIT       
         JMP ($A002)       
;
;------- LOAD UND SAVE-BEFEHLE -----
;
MERGE    JSR LOSAV         
         LDA #$FF          
         TAY               
         JSR SET14         
         JSR ZEILSUCH      
         LDX $5F           
         LDY $60           
         BNE LOADIN        
         RTS               
;
LOAD     JSR LOSAV         
         LDX $2B           
         LDY $2C           
LOADIN   LDA #$00          
         STA $0A           
         JSR LOADB         
         BCS FEHLER        
         STX $2D           
         STY $2E           
         LDA #$00          
         TAY               
ENDELOOP STA ($2D),Y       
         INY               
         CPY #$03          
         BNE ENDELOOP      
         JSR NULLZEILE     
FEHLER   LDY #$0B          
         STY $D3           
         JSR STATUS        
         JMP BINDNUMLI     
;
SAVE     JSR LOSAV         
         JSR SAVEB         
         JMP FEHLER        
;
BLOSALO  JSR CHRGET        
         CMP #"S"          
         BEQ BLOCKSAVE     
         CMP #"L"          
         BEQ BLOCKLOAD     
         RTS               
;
BLOCKSAVE JSR NOSTOP        
         BCS NOSAVE1       
         JSR LOSAV         
         LDA BLOCKANF      
         LDY BLOCKANF+1    
         JSR SET14         
         JSR ZEILSUCH      
         LDA $5F           
         LDY $60           
         STA $C1           
         STY $C2           
         LDA BLOCKEND      
         LDY BLOCKEND+1    
         JSR SET14         
         JSR ZEILSUCH      
         LDY #$00          
         LDA ($5F),Y       
         STA $AE           
         INY               
         LDA ($5F),Y       
         STA $AF           
         LDA #$61          
         STA $B9           
         JSR IECOPEN       
         LDA $BA           
         JSR LISTEN        
         LDA $B9           
         JSR SEKLIST       
         JSR SETZEIGER     
         LDA #$00          
         JSR IECOUT        
         LDA #$E0          
         JSR IECOUT        
         LDY #$00          
STARTLOOP LDA BLOCKANF,Y    
         JSR IECOUT        
         INY               
         CPY #$04          
         BNE STARTLOOP     
         LDY #$00          
         JSR SAVEIN        
         JMP FEHLER        
;
NOSAVE1  RTS               
;
BLOCKLOAD JSR LOSAV         
         LDA #$00          
         STA $0A           
         LDX #$00          
         LDY #$E0          
         JSR LOADB         
         TXA               
         SEC               
         SBC #$03          
         STA BLOCKLAENGE   
         TYA               
         SBC #$E0          
         STA BLOCKLAENGE+1 
         LDA #$2A          
         STA $0426+120     
         JMP FEHLER        
;
;------ DIRECTORY AUSGEBEN -------
;
FILES    PLA               
         PLA               
         JSR NOBEF         
         LDA FLAG          
         ORA #$20          
         STA FLAG          
         JSR CURPOS        
         JSR SCRCLEAR      
         JSR STARTCUR      
         LDA #"$"          
         STA $FB           
         LDA #$FB          
         STA $BB           
         LDA #$00          
         STA $BC           
         LDA #$01          
         STA $B7           
         LDA DEVICE        
         STA $BA           
         LDA #$60          
         STA $B9           
         JSR IECOPEN       
         LDA $BA           
         JSR TALK          
         LDA $B9           
         JSR SEKTALK       
         LDA #$00          
         STA $90           
         LDY #$03          
         STY $FB           
         JSR IECIN         
         LDY $90           
         BNE FILOOPIN      
         BEQ FIRST         
FILOOP1  STY $FB           
         JSR IECIN         
FIRST    STA $FC           
         LDY $90           
         BNE FILOOP4       
         JSR IECIN         
         LDY $90           
         BNE FILOOP4       
         LDY $FB           
         DEY               
         BNE FILOOP1       
         LDX $FC           
         JSR INTOUT        
         LDA #" "          
         JSR BSOUT         
FILOOP3  JSR IECIN         
         LDX $90           
         BNE FILOOP4       
         TAX               
         BEQ FILOOP2       
         JSR BSOUT         
         JMP FILOOP3       
FILOOP2  LDA #$0D          
         JSR BSOUT         
         LDX $D6           
         STX LISTEND       
         JSR DOWN          
         CPX #$18          
         BNE NOLASTZEI     
         JSR WAITTAST3     
NOLASTZEI LDY #02           
         BNE FILOOP1       
;
FILOOP4  DEC LISTEND       
         JSR WAITTAST3     
FILOOPIN JSR IECCLOSE      
         JSR COMSTART      
         LDA #$0B          
         STA $D3           
         JSR STATUS        
         JMP SEITLIST      
;
;FEHLERKANAL IN DER KOMMDOZEILE AUSGEBEN
;
STATUS   LDA $D6           
         PHA               
         LDA $D3           
         PHA               
         LDA ZEILSTART     
         PHA               
         LDA ZEILEND       
         PHA               
         LDA #$0B          
         STA ZEILSTART     
         LDA #$25          
         STA ZEILEND       
         JSR ZEILCLR       
         JSR COMSTART      
         LDA #<(TEXT2)     
         LDY #>(TEXT2)     
         JSR SETSTRING     
         PLA               
         STA ZEILEND       
         PLA               
         STA ZEILSTART     
         PLA               
         TAY               
         PLA               
         TAX               
         JSR PLOT          
         LDA FLAG          
         AND #$DF          
         STA FLAG          
         JSR NEWVEKTOR     
         JSR HYSTATUS      
         JMP OLDVEKTOR     
;
;--- KOMMANDO AN LAUFWERK SENDEN ---
;
COMAND   JSR NEWVEKTOR     
         JSR HYCOMAND      
         JSR OLDVEKTOR     
         JMP STATUS        
;
;------- EINLESEN EINER ZAHL -------
;
HOLZAHL  JSR CHRGET        
         BCS ZAHLNO        
         JSR ZAHLIN        
         LDX $14           
         LDY $15           
ZAHLNO   RTS               
;
;-- SETZT GERAETENUMMER UND FILENAMEN --
;
LOSAV    JSR CHRGET        
         BEQ LOSAVERR      
         JSR GETPAR        
         LDY #$00          
         LDX DEVICE        
         JMP FILPAR        
LOSAVERR PLA               
         PLA               
         RTS               
;
;- WARTET AUF BEFEHL IM DIRECTORY-MODE -
;
WAITTAST3 LDX #$06          
         LDY #$04          
         JSR PLOT          
WAUTL    LDY $D3           
         LDA ($D1),Y       
         STA $CE           
         EOR #$80          
         STA ($D1),Y       
TASTL    LDA $C6           
         BEQ TASTL         
         SEI               
         LDA $CE           
         STA ($D1),Y       
         JSR GETPUF        
         CMP #""          
         BEQ FILESDOWN     
         CMP #"�"          
         BEQ FILEUP        
         CMP #"�"          
         BEQ RETURNFILE1   
         LDY #$04          
INHALTLOOP CMP INITNAME,Y    
         BEQ RETURNFILE    
         DEY               
         BPL INHALTLOOP    
         CMP #"_"          
         BEQ ENDDIR        
         JMP WAUTL         
RETURNFILE1 LDX #$06          
         STX STARTZEIL     
         JSR SCRCLEAR      
         DEX               
         STX STARTZEIL     
         INX               
         LDY #$00          
         JMP PLOT          
FILESDOWN LDX $D6           
         CPX LISTEND       
         BCC SETFILEDWN    
         JMP WAUTL         
SETFILEDWN INX               
         .BY $24           
SETFILEUP DEX               
         JSR NOSCRIND      
         JMP WAUTL         
FILEUP   LDX $D6           
         CPX #$06          
         BNE SETFILEUP     
         JMP WAUTL         
ENDDIR   PLA               
         PLA               
         JMP FILOOPIN      
;
RETURNFILE LDA START,Y       
         STA $02           
         JSR IECCLOSE      
         PLA               
         PLA               
         LDX $D6           
         JSR NOSCRIND      
         LDY #$06          
UEBERTRLOOP LDA ($D1),Y       
         CMP #$22          
         BEQ RET1END       
         STA $0400+129,Y   
         INY               
         BNE UEBERTRLOOP   
RET1END  LDY $02           
         LDX #$00          
RET1LO   LDA ANFANG,Y      
         STA $0400+131,X   
         INY               
         INX               
         CPX #$04          
         BNE RET1LO        
         JSR SEITLIST      
         JMP KOMMANDO      
;
KOPF     .BY $70,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$72,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$72,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$6E
         .BY $5D,$1A,$05,$09
         .BY $0C,$05,$3A,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$5D,$13
         .BY $10,$01,$0C,$14
         .BY $05,$3A,$20,$20
         .BY $20,$20,$5D,$02
         .BY $19,$14,$05,$13
         .BY $3A,$20,$20,$20
         .BY $20,$20,$20,$5D
         .BY $6B,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$71,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$71,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$73
         .BY $5D,$0B,$0F,$0D
         .BY $0D,$01,$0E,$04
         .BY $0F,$3A,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$20
         .BY $20,$20,$20,$5D
         .BY $6D,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$40
         .BY $40,$40,$40,$7D
         .BY $20,$00       
.EN

