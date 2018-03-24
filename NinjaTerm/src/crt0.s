;
; Startup code for cc65 (Vic20 version)
;

        .export         __STARTUP__ : absolute = 1      ; Mark as startup
        .import         initlib, donelib
        .import         zerobss, push0
        .import         callmain
        .import         RESTOR, BSOUT, CLRCH
        .import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated
        .import         __STACKSIZE__                   ; Linker generated
        .import         TERMINAL, PUNTER_START, START_HERE, MAKECRCTABLE
        .importzp       ST

        .include        "zeropage.inc"
        .include        "vic20.inc"

; ------------------------------------------------------------------------
; Startup code

.segment        "STARTUP"

Start:

; Switch to the second charset.

        lda     #14
        jsr     BSOUT

        jsr     START_HERE

        lda     #$04
        ldx     #$02
        ldy     #$00
        jsr     $FFBA
        lda     #$08
        sta     $FC
        lda     #$00
        sta     $FD
        ldx     #$FC
        ldy     #$00
        lda     #$01
        jsr     $FFBD
        jsr     $FFC0

        jsr     16405
        jsr     16399

        rts

; ------------------------------------------------------------------------

.segment        "INIT"

zpsave: .res    zpspace

; ------------------------------------------------------------------------

.bss

spsave: .res    1
