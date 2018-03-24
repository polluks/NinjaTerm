.export punter

.segment "CODE"

modreg  = $dd01
datdir  = $dd03
rdtim   = $ffde
frmevl  = $c052
outnum  = $dddd
nmivec  = $0318
status  = $90
lognum  = $05
modem   = $02
secadr  = $03
setlfs  = $ffba
setnam  = $ffbd
open    = $ffc0
chkin   = $ffc6
chkout  = $ffc9
chrin   = $ffcf
chrout  = $ffd2
getin   = $ffe4
close   = $ffc3
clrchn  = $ffcc
clall   = $ffe7
readst  = $ffb7
plot    = $fff0
listen  = $ffb1
second  = $ff93
talk    = $ffb4
tksa    = $ff96
unlsn   = $ffae
untlk   = $ffab
acptr   = $ffa5
ciout   = $ffa8
numfil  = $98
locat   = $fb
nlocat  = $fd
xmobuf  = $fd
inpbuf  = $0200
txtcl   = 646
clcode  = $e921
scrtop  = 648
line    = 214
column  = 211
llen    = 213
qmode   = 212
imode   = 216
bcolor  = 0
tcolor  = 15
cursor  = 95              ;cursor "_"
left    = $9d
cursfl  = $fe
buffst  = $b2
bufptr  = $b0
grasfl  = $0313
duplex  = $12
tempch  = $05
tempcl  = $06
mulfil  = $6200
rinput  = $6f00
routpt  = $6e00
revtabup = $0380
recbufup = $6f00
RSNXTIN = $F14F
sndbufup = $6e00
bufptrreu = $6dfe
buffstreu = $6dff
buftop  = $61ff
mulcnt  = 2047
mulfln  = 2046
mlsall  = 2045
mulskp  = 2044
max     = $02
begpos  = $07
endpos  = $ac
bufflg  = $0b
buffl2  = $0c
buffoc  = $10
pnt10   = $0200
pnt11   = $028d
pnt12   = $029b
pnt13   = $029c
pnt14   = $02a1
pbuf2   = $0400
xmoscn  = pbuf2
wr_sptr = $029e           ;    .byte $00  ; write-pointer into send buffer
rd_sptr = $029d           ;  .byte $00  ; read-pointer into send buffer
wr_rptr = $029b           ; write-pointer into receive buffer
rd_rptr = $029c           ;    .byte $00  ; read-pointer into receive buffer
can     = 24
ack     = 6
nak     = 21
eot     = 4
soh     = 1
cpmeof  = 26
ca      = 193             ;cap letters!
b       = 194
c       = 195
d       = 196
e       = 197
f       = 198
g       = 199
h       = 200
i       = 201
l       = 204
o       = 207
m       = 205
n       = 206
cp      = 208
q       = 209
cr      = 210
cs      = 211
t       = 212
u       = 213
v       = 214
w       = 215
cx      = 216
cy      = 217
z       = 219
;
;PUNTER
;
punter:                    ; source code $0812
;referenced by old $6000 addresses
p49152:  lda     #$00
        .byte    $2c
p49155:  lda     #$03
        .byte    $2c
p49158:  lda     #$06
        .byte    $2c
p49161:  lda     #$09      ;this one goes to?
        .byte    $2c
p49164:  lda     #$0c
        .byte    $2c
p49167:  lda     #$0f
        nop
p49170:  jmp     pnt23
p49173:  jmp     pnt109
pnt23:   sta     $62
        tsx
        stx     pbuf+28
        lda     #<pnttab
        clc
        adc     $62
        sta     pntjmp+1
        lda     #>pnttab
        adc     #$00
        sta     pntjmp+2
pntjmp:  jmp     pnttab
pnttab:  jmp     PBbsHandshake
        jmp     PReceive2
        jmp     PTransmit2
        jmp     PReceive1
        jmp     PTransmit1
        jmp     PTerminal
pnt27:  .asciiz    "GOOBADACKS/BSYN"
;pnt27 .asciiz "goobadacks/bsyn"
PBbsHandshake:
        sta     pbuf+5
        lda     #$00
        sta     pbuf
        sta     pbuf+1
        sta     pbuf+2
pnt29:   lda     #$00
        sta     pbuf+6
        sta     pbuf+7
pnt30:   jsr     pnt114    ;getnum get #5,a$ - check for c= key
        jsr     pnt38     ;pnt 122
        lda     $96
        bne     pnt35     ;if no chr, do timer check
        lda     pbuf+1
        sta     pbuf
        lda     pbuf+2
        sta     pbuf+1
        lda     pnt10
        sta     pbuf+2
        lda     #$00
        sta     pbuf+4
        lda     #$01
        sta     pbuf+3
pnt31:   lda     pbuf+5
        bit     pbuf+3
        beq     pnt33
        ldy     pbuf+4
        ldx     #$00
pnt32:   lda     pbuf,x
        cmp     pnt27,y
        bne     pnt33
        iny
        inx
        cpx     #$03
        bne     pnt32
        jmp     pnt34
pnt33:   asl     pbuf+3
        lda     pbuf+4
        clc
        adc     #$03
        sta     pbuf+4
        cmp     #$0f
        bne     pnt31
        jmp     pnt111
pnt34:   lda     #$ff
        sta     pbuf+6
        sta     pbuf+7
        jmp     pnt30
pnt35:   inc     pbuf+6
        bne     pnt36
        inc     pbuf+7
pnt36:   lda     pbuf+7
        ora     pbuf+6
        beq     pnt37
        lda     pbuf+6
        cmp     #$07
        lda     pbuf+7
        cmp     #$14
        bcc     pnt30
        lda     #$01
        sta     $96
        jmp     pnt101
pnt37:   lda     #$00
        sta     $96
        rts
        nop
pnt38:   jmp     pnt122
        nop
        nop
pnt39:
        cmp     $029c
        beq     pnt40

        ldy     $029c
        lda     ($f7),y
        pha
        inc     $029c
        lda     #$00
        sta     $96
        pla
        sta     pnt10
        pla
        tay
        jmp     pnt41
pnt40:
        lda     #$02
        sta     $96
        lda     #$00
        sta     pnt10
        pla
        tay
pnt41:   pha
        lda     #$03
        sta     $ba
        pla
        rts
pnt42:
        pha
        txa
        pha
        tya
        pha
        lda     667       ;clear modinput buf
        sta     668
;        jsr     enablexfer
        pla
        tay
        pla
        tax
        pla
        ldx     #$05
        jsr     chkout
        ldx     #$00
pnt43:   lda     pnt27,y
        jsr     chrout
        iny
        inx
        cpx     #$03
        bne     pnt43
        jmp     pnt118
pnt44:   sta     pbuf+8
        lda     #$00
        sta     pbuf+11
pnt45:   lda     #$02
        sta     $62
        ldy     pbuf+8
        jsr     pnt42
pnt46:   lda     #$04
        jsr     PBbsHandshake
        lda     $96
        beq     pnt47
        dec     $62
        bne     pnt46
        jmp     pnt45
pnt47:   ldy     #$09
        jsr     pnt42
        lda     pbuf+13
        beq     pnt48
        lda     pbuf+8
        beq     pnt50
pnt48:   lda     pbuf2+4
        sta     pbuf+9
        sta     pbuf+23
        jsr     pnt65
        lda     $96
        cmp     #$01
        beq     pnt49
        cmp     #$02
        beq     pnt47
        cmp     #$04
        beq     pnt49
        cmp     #$08
        beq     pnt47
pnt49:   rts
pnt50:   lda     #$10
        jsr     PBbsHandshake
        lda     $96
        bne     pnt47
        lda     #$0a
        sta     pbuf+9
pnt51:   ldy     #$0c
        jsr     pnt42
        lda     #$08
        jsr     PBbsHandshake
        lda     $96
        beq     pnt52
        dec     pbuf+9
        bne     pnt51
pnt52:   rts
pnt53:   lda     #$01
        sta     pbuf+11
pnt54:   lda     pbuf+30
        beq     pnt55
        ldy     #$00
        jsr     pnt42
pnt55:   lda     #$0b
        jsr     PBbsHandshake
        lda     $96
        bne     pnt54
        lda     #$00
        sta     pbuf+30
        lda     pbuf+4
        cmp     #$00
        bne     pnt59
        lda     pbuf+13
        bne     pnt61
        inc     pbuf+25
        bne     pnt56
        inc     pbuf+26
pnt56:   jsr     pnt79
        ldy     #$05
        iny
        lda     ($64),y
        cmp     #$ff
        bne     pnt57
        lda     #$01
        sta     pbuf+13
        lda     pbuf+22
        eor     #$01
        sta     pbuf+22
        jsr     pnt79
        jsr     pnt77
        jmp     pnt58
pnt57:   jsr     pnt74
pnt58:   lda     #'-'
        .byte    $2c
pnt59:   lda     #':'
        jsr     pnt107
        ldy     #$06
        jsr     pnt42
        lda     #$08
        jsr     PBbsHandshake
        lda     $96
        bne     pnt58
        jsr     pnt79
        ldy     #$04
        lda     ($64),y
        sta     pbuf+9
        jsr     pnt80
        pha
        txa
        pha
        tya
        pha
        lda     667       ;clear modinput buf
        sta     668
;        jsr     enablexfer
        pla
        tay
        pla
        tax
        pla
        ldx     #$05
        jsr     chkout
        ldy     #$00
pnt60:   lda     ($64),y
        jsr     pnt123
        iny
        cpy     pbuf+9
        bne     pnt60
        jsr     clrchn
        lda     #$00
        rts
pnt61:   lda     #'*'
        jsr     pnt107
        ldy     #$06
        jsr     pnt42
        lda     #$08
        jsr     PBbsHandshake
        lda     $96
        bne     pnt61
        lda     #$0a
        sta     pbuf+9
pnt62:   ldy     #$0c
        jsr     pnt42
        lda     #$10
        jsr     PBbsHandshake
        lda     $96
        beq     pnt63
        dec     pbuf+9
        bne     pnt62
pnt63:   lda     #$03
        sta     pbuf+9
pnt64:   ldy     #$09
        jsr     pnt42
        lda     #$00
        jsr     PBbsHandshake
        dec     pbuf+9
        bne     pnt64
        lda     #$01
        rts
pnt65:   ldy     #$00
pnt66:   lda     #$00
        sta     pbuf+6
        sta     pbuf+7
pnt67:   jsr     pnt114
        jsr     pnt38
        lda     $96
        bne     pnt70
        lda     pnt10
        sta     pbuf2,y
        cpy     #$03
        bcs     pnt68
        sta     pbuf,y
        cpy     #$02
        bne     pnt68
        lda     pbuf
        cmp     #$41
        bne     pnt68
        lda     pbuf+1
        cmp     #$43
        bne     pnt68
        lda     pbuf+2
        cmp     #$4b
        beq     pnt69
pnt68:   iny
        cpy     pbuf+9
        bne     pnt66
        lda     #$01
        sta     $96
        rts
pnt69:   lda     #$ff
        sta     pbuf+6
        sta     pbuf+7
        jmp     pnt67
pnt70:   inc     pbuf+6
        bne     pnt71
        inc     pbuf+7
pnt71:   lda     pbuf+6
        ora     pbuf+7
        beq     pnt73
        lda     pbuf+6
        cmp     #$06
        lda     pbuf+7
        cmp     #$10
        bne     pnt67
        lda     #$02
        sta     $96
        cpy     #$00
        beq     pnt72
        lda     #$04
        sta     $96
pnt72:   jmp     pnt101
pnt73:   lda     #$08
        sta     $96
        rts
pnt74:   lda     pbuf+22
        eor     #$01
        sta     pbuf+22
        jsr     pnt79
        ldy     #$05
        lda     pbuf+25
        clc
        adc     #$01
        sta     ($64),y
        iny
        lda     pbuf+26
        adc     #$00
        sta     ($64),y
        ldx     #$02
        jsr     chkin
        ldy     #$07
pnt75:   jsr     chrin
        sta     ($64),y
        iny
        jsr     readst
        bne     pnt76
        cpy     pbuf+24
        bne     pnt75
        tya
        pha
        jmp     pnt78
pnt76:   tya
        pha
        ldy     #$05
        iny
        lda     #$ff
        sta     ($64),y
        jmp     pnt78
pnt77:   pha
pnt78:   jsr     clrchn
        jsr     pnt109
        jsr     pnt103
        jsr     pnt109
        ldy     #$04
        lda     ($64),y
        sta     pbuf+9
        jsr     pnt80
        pla
        ldy     #$04
        sta     ($64),y
        jsr     pnt81
        rts
pnt79:   lda     #<pbuf2
        sta     $64
        lda     pbuf+22
        clc
        adc     #>pbuf2
        sta     $65
        rts
pnt80:   lda     #<pbuf2
        sta     $64
        lda     pbuf+22
        eor     #$01
        clc
        adc     #>pbuf2
        sta     $65
        rts
pnt81:   lda     #$00
        sta     pbuf+18
        sta     pbuf+19
        sta     pbuf+20
        sta     pbuf+21
        ldy     #$04
pnt82:   lda     pbuf+18
        clc
        adc     ($64),y
        sta     pbuf+18
        bcc     pnt83
        inc     pbuf+19
pnt83:   lda     pbuf+20
        eor     ($64),y
        sta     pbuf+20
        lda     pbuf+21
        rol     a
        rol     pbuf+20
        rol     pbuf+21
        iny
        cpy     pbuf+9
        bne     pnt82
        ldy     #$00
        lda     pbuf+18
        sta     ($64),y
        iny
        lda     pbuf+19
        sta     ($64),y
        iny
        lda     pbuf+20
        sta     ($64),y
        iny
        lda     pbuf+21
        sta     ($64),y
        rts
PTransmit2:
        lda     #$00
        sta     pbuf+13
        sta     pbuf+12
        sta     pbuf+29
        lda     #$01
        sta     pbuf+22
        lda     #$ff
        sta     pbuf+25
        sta     pbuf+26
        jsr     pnt80
        ldy     #$04
        lda     #$07
        sta     ($64),y
        jsr     pnt79
        ldy     #$05
        lda     #$00
        sta     ($64),y
        iny
        sta     ($64),y
pnt85:   jsr     pnt53
        beq     pnt85
pnt86:   lda     #$00
        sta     pnt10
        rts
PReceive2:
        lda     #$01
        sta     pbuf+25
        lda     #$00
        sta     pbuf+26
        sta     pbuf+13
        sta     pbuf+22
        sta     pbuf2+5
        sta     pbuf2+6
        sta     pbuf+12
        lda     #$07
        sta     pbuf2+4
        lda     #$00
pnt88:   jsr     pnt44
        lda     pbuf+13
        bne     pnt86
        jsr     pnt93
        bne     pnt92
        jsr     clrchn
        lda     pbuf+9
        cmp     #$07
        beq     pnt90
        ldx     #$02
        jsr     chkout
        ldy     #$07
pnt89:   lda     pbuf2,y
        jsr     chrout
        iny
        cpy     pbuf+9
        bne     pnt89
        jsr     clrchn
pnt90:   lda     pbuf2+6
        cmp     #$ff
        bne     pnt91
        lda     #$01
        sta     pbuf+13
        lda     #'*'
        .byte    $2c
pnt91:   lda     #'-'
        jsr     goobad
        jsr     pnt109
        lda     #$00
        jmp     pnt88
pnt92:   jsr     clrchn
        lda     #':'
        jsr     goobad
        lda     pbuf+23
        sta     pbuf2+4
        lda     #$03
        jmp     pnt88
pnt93:   lda     pbuf2
        sta     pbuf+14
        lda     pbuf2+1
        sta     pbuf+15
        lda     pbuf2+2
        sta     pbuf+16
        lda     pbuf2+3
        sta     pbuf+17
        jsr     pnt79
        lda     pbuf+23
        sta     pbuf+9
        jsr     pnt81
        lda     pbuf2
        cmp     pbuf+14
        bne     pnt94
        lda     pbuf2+1
        cmp     pbuf+15
        bne     pnt94
        lda     pbuf2+2
        cmp     pbuf+16
        bne     pnt94
        lda     pbuf2+3
        cmp     pbuf+17
        bne     pnt94
        lda     #$00
        rts
pnt94:   lda     #$01
        rts

PReceive1:
        lda     #$00
        sta     pbuf+25
        sta     pbuf+26
        sta     pbuf+13
        sta     pbuf+22
        sta     pbuf+12
        lda     #$07
        clc
        adc     #$01
        sta     pbuf2+4
        lda     #$00
pnt96:   jsr     pnt44
        lda     pbuf+13
        bne     pnt98
        jsr     pnt93
        bne     pnt97
        lda     pbuf2+7
        sta     pbuf+27
        lda     #$01
        sta     pbuf+13
        lda     #$00
        jmp     pnt96
pnt97:   lda     pbuf+23
        sta     pbuf2+4
        lda     #$03
        jmp     pnt96
pnt98:   lda     #$00
        sta     pnt10
        rts
PTransmit1:
        lda     #$00
        sta     pbuf+13
        sta     pbuf+12
        lda     #$01
        sta     pbuf+22
        sta     pbuf+29
        lda     #$ff
        sta     pbuf+25
        sta     pbuf+26
        jsr     pnt80
        ldy     #$04
        lda     #$07
        clc
        adc     #$01
        sta     ($64),y
        jsr     pnt79
        ldy     #$05
        lda     #$ff
        sta     ($64),y
        iny
        sta     ($64),y
        ldy     #$07
        lda     pbuf+27
        sta     ($64),y
        lda     #$01
        sta     pbuf+30
pnt100:  jsr     pnt53
        beq     pnt100
        lda     #$00
        sta     pnt10
        rts
pnt101:  inc     pbuf+12
        lda     pbuf+12
        cmp     #$03
        bcc     pnt102
        lda     #$00
        sta     pbuf+12
        lda     pbuf+11
        beq     pnt103
        bne     pnt106
pnt102:  lda     pbuf+11
        beq     pnt106
pnt103:  ldx     #$00
pnt104:  ldy     #$00
pnt105:  iny
        bne     pnt105
        inx
        cpx     #$78
        bne     pnt104
pnt106:  rts
pnt107:  pha
        lda     pbuf+25
        ora     pbuf+26
        beq     pnt108
        lda     pbuf+29
        bne     pnt108
        pla
        jsr     goobad
        pha
pnt108:  pla
        rts
pnt109:  jsr     RSNXTIN
        lda     pnt14
        cmp     #$80
        beq     pnt109
        cmp     #$92
        beq     pnt109
        rts
PTerminal:
        rts     ; It's been removed
pnt111:  ldx     #$00
pnt112:  lda     pbuf2,x
        cmp     #$0d
        bne     pnt113
        inx
        cpx     #$03
        bcc     pnt112
        jmp     pnt120
pnt113:  jmp     pnt29
pnt114:  lda     pnt11     ;$028d - check c= key;getnum routine
        cmp     #$02
        bne     pnt116
pnt115:  pla
        tsx
        cpx     pbuf+28
        bne     pnt115
pnt116:  lda     #$01
        sta     pnt10
pnt117:  rts
        brk
pnt118:  jsr     clrchn
pnt119:
        lda     $dd01
        and     #$00      ;and #$10 for carrier
        beq     pnt117    ;check and abort
pnt120:

        tsx
        cpx     pbuf+28
        beq     pnt121
        pla
        sec
        bcs     pnt120
pnt121:

        lda     #$80
        sta     pnt10
        jsr     clrchn
        rts
pnt122:
        tya
        pha
        jsr     pnt119
        lda     $029b
        jmp     pnt39
pnt123:
        pha
        jsr     pnt119
        pla
        jmp     chrout
        brk

goobad:
        sta     1844
        cmp     #'/'
        beq     goober
        cmp     #'*'
        bne     goob2
goober:  rts
goob2:   cmp     #':'
        beq     goob3
        ldx     #3
        bne     goob4
goob3:   ldx     #25
goob4:   inc     1837,x
        lda     1837,x
        cmp     #':'
        bcc     goober
        lda     #'0'
        sta     1837,x
        dex
        bpl     goob4
        rts
;
ptrtxt:  .byte    13,13,5
        .byte   "NEW Punter ",0
upltxt:  .byte    "Up",0
dowtxt:  .byte    "Down",0
lodtxt:  .byte    "Load.",13,0
flntxt:  .byte    "Enter Filename: ",0
xfrmed:  .byte    13,158,32,32,00
xfrtxt:  .byte    "Loading: ",159,0
;xf2txt:  .asciiz    13,5,'  pRESS c= TO ABORT.',13,13,00
abrtxt:  .byte    "Aborted. ",13,0
mrgtxt:  .byte    153,32,"Good Blocks: ",5,"000",5,"   -   ",153,"Bad Blocks: ",5,"000",13,0
gfxtxt:  .byte    153,"Graphics",0
gfxtxt2: .byte    18,31,'c',154,'/',159,'g',146,158,0
asctxt:  .byte    159,"Ascii",0
rdytxt:  .byte    " Terminal Ready.",155,13,13,0
rdytxt2: .byte    " Term Activated.",155,13,13,0
dsctxt:  .byte    13,5,"Disconnecting...",13,13,0
drtype:  .byte    'D','S','P','U','R'
drtyp2:  .byte    'E','E','R','S','E'
drtyp3:  .byte    'L','Q','G','S','L'
drform:  .byte    158,2,157,157,5,6,32,159,14,153,32,63,32,0
pbuf:    .byte    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
