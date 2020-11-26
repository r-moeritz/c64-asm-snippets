;tab-width=16

;; Code von https://www.c64-wiki.de/wiki/Centronics-Schnittstelle

*= $033c			; Assemblieren in den Kassettenpuffer
			; Aufruf aus Basic mit SYS 828

vecCHROUT = $326
vecCHKOUT = $320

CIA2      = $dd00
CIA2_PRA  = CIA2
CIA2_PRB  = CIA2 + 1
CIA2_DDRA = CIA2 + 2
CIA2_DDRB = CIA2 + 3
CIA2_ICR  = CIA2 + 13

; CHROUT-Vektor umbiegen
init	lda #<newCHROUT
	sta vecCHROUT
	lda #>newCHROUT
	sta vecCHROUT + 1

; CHKOUT-Vektor umbiegen
	lda #<newCHKOUT
	sta vecCHKOUT
	lda #>newCHKOUT
	sta vecCHKOUT + 1

; CIA-Register initialisieren
	lda CIA2_PRA 
	ora #$04		; STROBE auf HIGH
	sta CIA2_PRA
	lda #$10
	sta CIA2_ICR		; IRQ durch CIA2_ICR-Flag ausschalten
	lda CIA2_DDRA
	ora #$04		; Datenrichtung für STROBE auf Ausgabe
	sta CIA2_DDRA
	lda #$ff
	sta CIA2_DDRB		; Datenrichtung für DATA auf Ausgabe
	
	lda #$00
	beq toCentronics	; NULL-Zeichen ausgeben, um BUSY-Flag zu intialisieren

newCHROUT	pha		; Zeichen auf Stack sichern
	lda $9a		; aktuelle Gerätenummer lesen
	cmp #$04		; auf Ausgabegerät 4 testen
	beq waitForBUSY
	jmp $f1cb		; wenn nicht, weiter in Originalroutine
	
waitForBUSY	lda CIA2_ICR
	and #$10
	beq waitForBUSY		; warten, bis BUSY-Flag gesetzt	
	pla		
			; Zeichen vom Stack holen ...
toCentronics	sta CIA2_PRB		; und auf den Userport legen
	lda CIA2_PRA
	and #!$04		; STROBE auf Low ...
	sta CIA2_PRA
	ora #$04		; und sofort wieder HIGH
	sta CIA2_PRA
	
	clc		; Fehlerflag löschen
	rts		; und fertig!

newCHKOUT	jsr $f30f		; File-Index ermitteln
	beq setFileParams
	jmp $f701		; File not open Error
	
setFileParams	jsr $f31f		; aktuelle File-Parameter in Zeropage hinterlegen

	lda $ba		; Gerätenummer des Files ermitteln
	cmp #$04		; auf Ausgabegerät 4 testen
	beq setDeviceNum	; wenn nicht, dann
	cmp #$00
	jmp $f25b		; weiter in originaler CHKOUT-Routine

setDeviceNum	sta $9a		; ansonsten aktuelle Gerätenummer setzen
	clc		; Fehlerflag löschen
	rts		; und fertig!