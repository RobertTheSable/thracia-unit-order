lorom

; y = used for current position in unit array
; x = used for current position in "pointer" array

ORG $85FA4D
	jml unitRoutine

ORG $F4CC20
unitRoutine:
	php
	pha
	phx
	phy
	phb
	sep #$30
	lda #$7e
	pha
	plb
	rep #$30
	ldx #$0000
	ldy #$0000
initialLoop:
	lda $b605, x
	cmp #$0000
	beq endloop
	tay
	lda $0005, y
	BIT #$0200
	bne skiptonext_outer		;skip unit until we find one that's not selected
findfirstselected:
	lda $b605, x			; now we've found one that's not selected
	cmp #$0000
	beq endloop
	tay
	lda $0005, y
	BIT #$0200
	beq skiptonext_inner1		; skip unti we've found a selected unit
startInner2:
	phx
	phy
	 ;copy selected unit to temp
	 ; lda $B605, x
	 ; sta $7e1000			; copy pointer
	 tyx				; set current unit as source
	 ldy #$1002			; set temp as destination
	 lda #$0040			; load size to copy
	 mvn $7e, $7e			; copy to temp
	 ply
	 plx
	 phx
	 phy
decrementLoop:
	dex
	dex
	bpl keepgoing
	bra endDecLoop
keepgoing:
	lda $b605, x			; now we've found one that's not selected
	cmp #$0000
	beq exitLoop
	tay
	lda $0005, y
	BIT #$0200
	bne endDecLoop
	phx
	lda $B607, x
	PHA
	lda $b605, x			; load current pointer
	;sta $B607, x			; store pointer in next position
	tax
	PLY
	; copy current unit to next position
	lda #$0040			; load size to copy
	mvn $7e, $7e			; copy to temp
	plx
	bra decrementLoop
exitLoop:
	ply
	plx
	BRL endloop
endDecLoop:
	inx
	inx
	; copy temp to current position
	; lda $7e1000			; copy pointer
	lda $b605, x
	tay				; set current unit as destinatopn
	ldx #$1002			; set temp as source
	lda #$0040			; load size to copy
	mvn $7e, $7e			; copy to temp
	ply
	plx
skiptonext_inner1:
	inx
	inx
	brl findfirstselected
skiptonext_outer: 
	inx
	inx
	brl initialLoop
endloop:
	plb
	ply
	plx
	pla
	plp
	LDA #$A1E0
	STA $052D
	jml $85FA53 ; this is the end