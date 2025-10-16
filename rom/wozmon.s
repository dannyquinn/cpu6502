.setcpu "65C02"
.include "constant.s"
.segment "woz"

xaml  = $24             ; Last "opened" location Low
xamh  = $25             ; Last "opened" location High
stl   = $26             ; Store address Low
sth   = $27             ; Store address High
l     = $28             ; Hex value parsing Low
h     = $29             ; Hex value parsing High
ysav  = $2a             ; Used to see if hex value is given
mode  = $2b             ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

in    = $0200           ; Input buffer

wozman:
@reset:
    lda #$1f            ; 8-N-1, 19200 baud.
    sta ACIA_CONTROL
    lda #$0b            ; No parity, no echo, no interrupts.
    sta ACIA_COMMAND
    lda #$1b            ; Begin with escape.

@notcr:
    cmp #$08            ; Backspace key?
    beq @backspace      ; Yes.
    cmp #$1b            ; ESC?
    beq @escape         ; Yes.
    iny                 ; Advance text index.
    bpl @nextchar       ; Auto ESC if line longer than 127.

@escape:
    lda #$5c            ; "\".
    jsr @echo           ; Output it.

@getline:
    lda #$0d            ; Send CR
    jsr @echo

    ldy #$01            ; Initialize text index.
@backspace:      
    dey                 ; Back up text index.
    bmi @getline        ; Beyond start of line, reinitialize.

@nextchar:
    lda ACIA_STATUS     ; Check status.
    and #$08            ; Key ready?
    beq @nextchar       ; Loop until ready.
    lda ACIA_DATA       ; Load character. B7 will be '0'.
    sta in,y            ; Add to text buffer.
    jsr @echo           ; Display character.
    cmp #$0d            ; CR?
    bne @notcr          ; No.

    ldy #$ff            ; Reset text index.
    lda #$00            ; For XAM mode.
    tax                 ; X=0.
@setblok:
    asl
@setstor:
    asl                 ; Leaves $7B if setting STOR mode.
    sta mode            ; $00 = XAM, $74 = STOR, $B8 = BLOK XAM.
@blskip:
    iny                 ; Advance text index.
@nextitem:
    lda in,y            ; Get character.
    cmp #$0d            ; CR?
    beq @getline        ; Yes, done this line.
    cmp #$2e            ; "."?
    bcc @blskip         ; Skip delimiter.
    beq @setblok        ; Set BLOCK XAM mode.
    cmp #$3a            ; ":"?
    beq @setstor        ; Yes, set STOR mode.
    cmp #$52            ; "R"?
    beq @run            ; Yes, run user program.
    stx l               ; $00 -> L.
    stx h               ;    and H.
    sty ysav            ; Save Y for comparison

@nexthex:
    lda in,y            ; Get character for hex test.
    eor #$30            ; Map digits to $0-9.
    cmp #$0a            ; Digit?
    bcc @dig            ; Yes.
    adc #$88            ; Map letter "A"-"F" to $FA-FF.
    cmp #$fa            ; Hex letter?
    bcc @nothex         ; No, character not hex.

@dig:
    asl
    asl                 ; Hex digit to MSD of A.
    asl
    asl

    ldx #$04            ; Shift count.

@hexshift:
    asl                 ; Hex digit left, MSB to carry.
    rol l               ; Rotate into LSD.
    rol h               ; Rotate into MSD's.
    dex                 ; Done 4 shifts?
    bne @hexshift       ; No, loop.
    iny                 ; Advance text index.
    bne @nexthex        ; Always taken. Check next character for hex.

@nothex:
    cpy ysav            ; Check if L, H empty (no hex digits).
    beq @escape         ; Yes, generate ESC sequence.

    bit mode            ; Test MODE byte.
    bvc @notstor        ; B6=0 is STOR, 1 is XAM and BLOCK XAM.

    lda l               ; LSD's of hex data.
    sta (stl,x)         ; Store current 'store index'.
    inc stl             ; Increment store index.
    bne @nextitem       ; Get next item (no carry).
    inc sth             ; Add carry to 'store index' high order.

@tonextitem:     
    jmp @nextitem       ; Get next command item.

@run:
    jmp (xaml)          ; Run at current XAM index.

@notstor:
    bmi @xamnext        ; B7 = 0 for XAM, 1 for BLOCK XAM.

    ldx #$02            ; Byte count.

@setadr: 
    lda l-1,x           ; Copy hex data to
    sta stl-1,x         ;  'store index'.
    sta xaml-1,x        ; And to 'XAM index'.
    dex                 ; Next of 2 bytes.
    bne @setadr         ; Loop unless X = 0.

@nxtprnt:
    bne @prdata         ; NE means no address to print.
    lda #$0d            ; CR.
    jsr @echo           ; Output it.
    lda xamh            ; 'Examine index' high-order byte.
    jsr @prbyte         ; Output it in hex format.
    lda xaml            ; Low-order 'examine index' byte.
    jsr @prbyte         ; Output it in hex format.
    lda #$3a            ; ":".
    jsr @echo           ; Output it.

@prdata:
    lda #$20            ; Blank.
    jsr @echo           ; Output it.
    lda (xaml,x)        ; Get data byte at 'examine index'.
    jsr @prbyte         ; Output it in hex format.

@xamnext:
    stx mode            ; 0 -> MODE (XAM mode).
    lda xaml
    cmp l               ; Compare 'examine index' to hex data.
    lda xamh
    sbc h
    bcs @tonextitem     ; Not less, so no more data to output.

    inc xaml
    bne @mod8chk        ; Increment 'examine index'.
    inc xamh

@mod8chk:
    lda xaml            ; Check low-order 'examine index' byte
    and #$07            ; For MOD 8 = 0
    bpl @nxtprnt        ; Always taken.

@prbyte:
    pha                 ; Save A for LSD.
    lsr
    lsr
    lsr                 ; MSD to LSD position.
    lsr
    jsr @prhex          ; Output hex digit.
    pla                 ; Restore A.

@prhex:
    and #$0f            ; Mask LSD for hex print.
    ora #$30            ; Add "0".
    cmp #$3a            ; Digit?
    bcc @echo           ; Yes, output it.
    adc #$06            ; Add offset for letter.

@echo:
    pha                 ; Save A.
    sta ACIA_DATA       ; Output character.
    lda #$ff            ; Initialize delay loop.
@txdelay:        
    dec                 ; Decrement A.
    bne @txdelay        ; Until A gets to 0.
    pla                 ; Restore A.
    rts                 ; Return.

wozmanend:
