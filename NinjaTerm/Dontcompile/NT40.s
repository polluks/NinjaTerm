*=$4000
NT40_INIT:
        ; Set 8x16 characters
        lda     $9003
        and     #%11111110
        ora     #%00000001
        sta     $9003
        rts

; .X = vertical line
; .Y = horizontal column
NT40_PLOT:
        clc
        txa
        ;ror
        ;adc     #$00
        sta     NT_CURX
        sty     NT_CURY
        rts

; .A = Character
NT40_CHROUT:
        pha
        lda     #<NT40_SCREEN0
        sta     $fb
        lda     #>NT40_SCREEN0
        sta     $fc

        lda     NT40_CURSCREEN          ; Writing to current screen?
        beq     NT40_CHROUT_PRINT       ; Yes

        clc                             ; No
        lda     #>NT40_SCREEN1
        adc     #$08
        sta     $fc                     ; Set $FC to second screen

NT40_CHROUT_PRINT:
        ldy     NT40_CURY               ; Loop through lines and keep adding
                                        ; 20 to the FB/FC pointers until
NT40_CHROUT_PRINT_LOOP1:                 ; we reach the character.
        lda     $fb
        clc
        adc     #20
        sta     $fb
        bcc     NT40_CHROUT_PRINT_CONTINUE

        lda     $fc                     ; Inc the page
        adc     $00
        sta     $fc

NT40_CHROUT_PRINT_CONTINUE:
        dey
        bne     NT40_CHROUT_PRINT_LOOP1

        lda     $FB               ; Found Row, Now find Character for X
        clc
        adc     NT40_CURX
        sta     $FB
        lda     $FC
        adc     #$00
        sta     $FC               ; FB/FC Points at character on screen

        ldy     #$00
        pla
        sta     ($fb),y           ; Store character


NT40_CHROUT_PRINT_LOOP2:
        clc
        adc     #20
        sta     $fb
        bcc     NT40_CHROUT_PRINT_CONTINUE2

        lda     $fc
        adc     $00
        sta     $fc

NT40_CHROUT_PRINT_CONTINUE2:
        dex
        bne     NT40_CHROUT_PRINT_LOOP2

        ldy     #$00
        pla
        sta     ($fb),y
        pha

        ; Display Character

        tay

        lda     #<SCREEN
        sta     $fb
        lda     #>SCREEN
        sta     $fc

NT40_CHROUT_FINDCHAR_LOOP:
        cpy     #$00
        beq     NT40_CHROUT_FOUND_CHAR

        clc
        lda     $fb
        adc     #$08
        sta     $fb
        lda     $fc
        adc     #$00
        sta     $fc
        dey
        jmp     NT40_CHROUT_FINDCHAR_LOOP

NT40_CHROUT_FOUND_CHAR:
        ldy     #$07

NT40_CHROUT_CACHE_LOOP:
        lda     ($fb),y
        and     NT40_UPPERLOWER
        sta     NT40_CACHE,y

        ; Odd or Even column
        lda     NT40_CURX
        and     #$01
        beq     NT40_CHROUT_ODD

        ; Even column
        lda     NT40_CACHE,y
        tax

        lda     NT40_UPPERLOWER
        and     #%00000001
        beq     @UPPER1

        clc
        txa
        rol
        rol
        rol
        rol
        tax

@UPPER1: txa
        and     #%11110000
        sta     NT40_CACHE,y

NT40_CHROUT_ODD:
        lda     NT40_CACHE,y
        tax

        lda     NT40_UPPERLOWER
        and     #%00000001
        bne     @LOWER1

        clc
        txa
        ror
        ror
        ror
        ror
        tax

@LOWER1: txa
        and     #%00001111
        sta     NT40_CACHE,y

        dey
        bne     NT40_CHROUT_CACHE_LOOP



        rts

NT40_CURX:
        .byte    $00

NT40_CURY:
        .byte    $00

NT40_CHARMASK:
        .byte    $00

NT40_CURSCREEN:
        .byte    $00

NT40_UPPERLOWER:
        .byte    $F0

NT40_REVERSE:
        .byte    $00

NT40_CACHE:
        .byte    $00,$00,$00,$00,$00,$00,$00,$00

*=$5000
NT40_SCREEN0:
        .word   $0800

NT40_SCREEN1:
        .word   $0800

*=$6000
CHARS_LOWER:
CHARS_UPPER:
        .byte    $00,$44,$AA,$AA,$88,$88,$66,$00 ; CHARACTER 0
        .byte    $40,$A0,$A0,$E4,$AA,$AA,$A6,$00 ; CHARACTER 1
        .byte    $C0,$A8,$A8,$C8,$AC,$AA,$CC,$00 ; CHARACTER 2
        .byte    $40,$A0,$84,$8A,$88,$AA,$44,$00 ; CHARACTER 3
        .byte    $C0,$A2,$A2,$A2,$A6,$AA,$C6,$00 ; CHARACTER 4
        .byte    $E0,$80,$84,$CA,$8E,$88,$E6,$00 ; CHARACTER 5
        .byte    $E0,$84,$8A,$C8,$8C,$88,$88,$00 ; CHARACTER 6
        .byte    $40,$A0,$84,$8A,$AA,$A6,$62,$0C ; CHARACTER 7
        .byte    $A0,$A8,$A8,$E8,$AC,$AA,$AA,$00 ; CHARACTER 8
        .byte    $E0,$40,$44,$40,$44,$44,$E4,$00 ; CHARACTER 9
        .byte    $60,$20,$20,$26,$22,$A2,$4A,$04 ; CHARACTER 10
        .byte    $A0,$A8,$E8,$CA,$AC,$AC,$AA,$00 ; CHARACTER 11
        .byte    $80,$84,$84,$84,$84,$84,$E4,$00 ; CHARACTER 12
        .byte    $A0,$E0,$EA,$AE,$AE,$AA,$AA,$00 ; CHARACTER 13
        .byte    $A0,$A0,$E0,$EC,$EA,$AA,$AA,$00 ; CHARACTER 14
        .byte    $40,$A0,$A4,$AA,$AA,$AA,$44,$00 ; CHARACTER 15
        .byte    $C0,$A0,$AC,$AA,$CA,$8C,$88,$08 ; CHARACTER 16
        .byte    $40,$A0,$A4,$AA,$AA,$E6,$62,$03 ; CHARACTER 17
        .byte    $C0,$A0,$A4,$AA,$C8,$A8,$A8,$00 ; CHARACTER 18
        .byte    $40,$A4,$8A,$48,$24,$A2,$44,$00 ; CHARACTER 19
        .byte    $E0,$44,$44,$4E,$44,$44,$44,$00 ; CHARACTER 20
        .byte    $A0,$A0,$AA,$AA,$AA,$AA,$66,$00 ; CHARACTER 21
        .byte    $A0,$A0,$AA,$AA,$AA,$AA,$44,$00 ; CHARACTER 22
        .byte    $A0,$A0,$AA,$AA,$AA,$EE,$AA,$00 ; CHARACTER 23
        .byte    $A0,$A0,$AA,$4A,$A4,$AA,$AA,$00 ; CHARACTER 24
        .byte    $A0,$A0,$A0,$4A,$4A,$46,$42,$0C ; CHARACTER 25
        .byte    $E0,$20,$2E,$42,$84,$88,$EE,$00 ; CHARACTER 26
        .byte    $EE,$88,$88,$88,$88,$88,$EE,$00 ; CHARACTER 27
        .byte    $22,$44,$44,$EE,$44,$CC,$AA,$00 ; CHARACTER 28
        .byte    $EE,$22,$22,$22,$22,$22,$EE,$00 ; CHARACTER 29
        .byte    $00,$22,$77,$22,$22,$22,$22,$22 ; CHARACTER 30
        .byte    $00,$00,$22,$44,$EE,$44,$22,$00 ; CHARACTER 31
        .byte    $00,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 32
        .byte    $22,$22,$22,$22,$00,$00,$22,$00 ; CHARACTER 33
        .byte    $AA,$AA,$AA,$00,$00,$00,$00,$00 ; CHARACTER 34
        .byte    $44,$44,$EE,$44,$EE,$44,$44,$00 ; CHARACTER 35
        .byte    $44,$EE,$CC,$EE,$66,$EE,$44,$00 ; CHARACTER 36
        .byte    $00,$CC,$CC,$22,$44,$BB,$33,$00 ; CHARACTER 37
        .byte    $44,$AA,$AA,$44,$AA,$99,$66,$00 ; CHARACTER 38
        .byte    $22,$44,$88,$00,$00,$00,$00,$00 ; CHARACTER 39
        .byte    $22,$44,$88,$88,$88,$44,$22,$00 ; CHARACTER 40
        .byte    $88,$44,$22,$22,$22,$44,$88,$00 ; CHARACTER 41
        .byte    $00,$44,$EE,$44,$EE,$44,$00,$00 ; CHARACTER 42
        .byte    $00,$44,$44,$EE,$44,$44,$00,$00 ; CHARACTER 43
        .byte    $00,$00,$00,$00,$00,$44,$44,$88 ; CHARACTER 44
        .byte    $00,$00,$00,$EE,$00,$00,$00,$00 ; CHARACTER 45
        .byte    $00,$00,$00,$00,$00,$CC,$CC,$00 ; CHARACTER 46
        .byte    $00,$22,$22,$44,$44,$88,$88,$00 ; CHARACTER 47
        .byte    $44,$EE,$AA,$AA,$AA,$EE,$44,$00 ; CHARACTER 48
        .byte    $44,$CC,$44,$44,$44,$44,$EE,$00 ; CHARACTER 49
        .byte    $44,$AA,$22,$44,$88,$88,$EE,$00 ; CHARACTER 50
        .byte    $44,$AA,$22,$44,$22,$AA,$44,$00 ; CHARACTER 51
        .byte    $AA,$AA,$AA,$EE,$22,$22,$22,$00 ; CHARACTER 52
        .byte    $EE,$88,$88,$44,$22,$AA,$44,$00 ; CHARACTER 53
        .byte    $44,$88,$CC,$AA,$AA,$AA,$44,$00 ; CHARACTER 54
        .byte    $EE,$22,$22,$44,$44,$44,$44,$00 ; CHARACTER 55
        .byte    $44,$AA,$AA,$44,$AA,$AA,$44,$00 ; CHARACTER 56
        .byte    $44,$AA,$AA,$66,$22,$AA,$44,$00 ; CHARACTER 57
        .byte    $00,$00,$22,$00,$00,$22,$00,$00 ; CHARACTER 58
        .byte    $00,$00,$22,$00,$00,$22,$22,$44 ; CHARACTER 59
        .byte    $22,$66,$CC,$88,$CC,$66,$22,$00 ; CHARACTER 60
        .byte    $00,$00,$EE,$00,$EE,$00,$00,$00 ; CHARACTER 61
        .byte    $88,$CC,$66,$22,$66,$CC,$88,$00 ; CHARACTER 62
        .byte    $44,$AA,$22,$44,$44,$00,$44,$00 ; CHARACTER 63
        .byte    $00,$00,$00,$00,$FF,$00,$00,$00 ; CHARACTER 64
        .byte    $44,$EA,$EA,$EE,$EA,$4A,$EA,$00 ; CHARACTER 65
        .byte    $4C,$4A,$4A,$4C,$4A,$4A,$4C,$40 ; CHARACTER 66
        .byte    $04,$0A,$08,$F8,$08,$0A,$04,$00 ; CHARACTER 67
        .byte    $0C,$0A,$FA,$0A,$0A,$0A,$0C,$00 ; CHARACTER 68
        .byte    $0E,$F8,$08,$0C,$08,$08,$0E,$00 ; CHARACTER 69
        .byte    $0E,$08,$08,$0C,$08,$F8,$08,$00 ; CHARACTER 70
        .byte    $44,$4A,$48,$48,$4A,$4A,$46,$40 ; CHARACTER 71
        .byte    $2A,$2A,$2A,$2E,$2A,$2A,$2A,$20 ; CHARACTER 72
        .byte    $0E,$04,$04,$84,$44,$24,$2E,$20 ; CHARACTER 73
        .byte    $2E,$24,$24,$14,$04,$04,$08,$00 ; CHARACTER 74
        .byte    $2A,$2A,$2A,$4C,$8C,$0A,$0A,$00 ; CHARACTER 75
        .byte    $88,$88,$88,$88,$88,$88,$8E,$F0 ; CHARACTER 76
        .byte    $8A,$8E,$4E,$4A,$2A,$2A,$1A,$10 ; CHARACTER 77
        .byte    $1A,$1A,$2A,$2E,$4E,$4A,$8A,$80 ; CHARACTER 78
        .byte    $F4,$8A,$8A,$8A,$8A,$8A,$84,$80 ; CHARACTER 79
        .byte    $FC,$1A,$1A,$1C,$18,$18,$18,$10 ; CHARACTER 80
        .byte    $04,$4A,$EA,$EA,$EA,$EE,$46,$01 ; CHARACTER 81
        .byte    $0C,$0A,$0A,$0C,$0A,$0A,$FA,$00 ; CHARACTER 82
        .byte    $64,$FA,$F8,$F4,$62,$2A,$04,$00 ; CHARACTER 83
        .byte    $4E,$44,$44,$44,$44,$44,$44,$40 ; CHARACTER 84
        .byte    $0A,$0A,$0A,$0A,$0A,$1A,$26,$20 ; CHARACTER 85
        .byte    $9A,$9A,$6A,$6A,$6A,$9A,$94,$00 ; CHARACTER 86
        .byte    $0A,$4A,$AA,$AA,$AE,$AE,$4A,$00 ; CHARACTER 87
        .byte    $4A,$EA,$54,$B4,$54,$4A,$4A,$00 ; CHARACTER 88
        .byte    $2A,$2A,$2A,$24,$24,$24,$24,$20 ; CHARACTER 89
        .byte    $4E,$E2,$F2,$F4,$F8,$E8,$4E,$00 ; CHARACTER 90
        .byte    $22,$22,$22,$22,$FF,$22,$22,$22 ; CHARACTER 91
        .byte    $88,$44,$88,$44,$88,$44,$88,$44 ; CHARACTER 92
        .byte    $22,$22,$22,$22,$22,$22,$22,$22 ; CHARACTER 93
        .byte    $0A,$05,$1A,$65,$EA,$65,$6A,$05 ; CHARACTER 94
        .byte    $F9,$74,$72,$39,$34,$32,$19,$14 ; CHARACTER 95
        .byte    $00,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 96
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 97
        .byte    $00,$00,$00,$00,$FF,$FF,$FF,$FF ; CHARACTER 98
        .byte    $FF,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 99
        .byte    $00,$00,$00,$00,$00,$00,$00,$FF ; CHARACTER 100
        .byte    $88,$88,$88,$88,$88,$88,$88,$88 ; CHARACTER 101
        .byte    $AA,$55,$AA,$55,$AA,$55,$AA,$55 ; CHARACTER 102
        .byte    $11,$11,$11,$11,$11,$11,$11,$11 ; CHARACTER 103
        .byte    $00,$00,$00,$00,$AA,$55,$AA,$55 ; CHARACTER 104
        .byte    $F4,$E9,$E2,$C4,$C9,$C2,$84,$89 ; CHARACTER 105
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 106
        .byte    $22,$22,$22,$22,$33,$22,$22,$22 ; CHARACTER 107
        .byte    $00,$00,$00,$00,$33,$33,$33,$33 ; CHARACTER 108
        .byte    $22,$22,$22,$22,$3B,$00,$00,$00 ; CHARACTER 109
        .byte    $00,$00,$00,$00,$EE,$22,$22,$22 ; CHARACTER 110
        .byte    $00,$00,$00,$00,$00,$00,$FF,$FF ; CHARACTER 111
        .byte    $00,$00,$00,$00,$33,$22,$22,$22 ; CHARACTER 112
        .byte    $22,$22,$22,$22,$FF,$00,$00,$00 ; CHARACTER 113
        .byte    $00,$00,$00,$00,$FF,$22,$22,$22 ; CHARACTER 114
        .byte    $22,$22,$22,$22,$EE,$22,$22,$22 ; CHARACTER 115
        .byte    $88,$88,$88,$88,$88,$88,$88,$88 ; CHARACTER 116
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 117
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 118
        .byte    $FF,$FF,$00,$00,$00,$00,$00,$00 ; CHARACTER 119
        .byte    $FF,$FF,$FF,$00,$00,$00,$00,$00 ; CHARACTER 120
        .byte    $00,$00,$00,$00,$00,$FF,$FF,$FF ; CHARACTER 121
        .byte    $10,$11,$11,$1A,$1A,$1C,$18,$F0 ; CHARACTER 122
        .byte    $00,$00,$00,$00,$CC,$CC,$CC,$CC ; CHARACTER 123
        .byte    $33,$33,$33,$33,$00,$00,$00,$00 ; CHARACTER 124
        .byte    $22,$22,$22,$22,$EE,$00,$00,$00 ; CHARACTER 125
        .byte    $CC,$CC,$CC,$CC,$00,$00,$00,$00 ; CHARACTER 126
        .byte    $CC,$CC,$CC,$CC,$33,$33,$33,$33 ; CHARACTER 127
        .byte    $FF,$BB,$55,$55,$77,$77,$99,$FF ; CHARACTER 128
        .byte    $BF,$5F,$5F,$1B,$55,$55,$59,$FF ; CHARACTER 129
        .byte    $3F,$57,$57,$37,$53,$55,$33,$FF ; CHARACTER 130
        .byte    $BF,$5F,$7B,$75,$77,$55,$BB,$FF ; CHARACTER 131
        .byte    $3F,$5D,$5D,$5D,$59,$55,$39,$FF ; CHARACTER 132
        .byte    $1F,$7F,$7B,$35,$71,$77,$19,$FF ; CHARACTER 133
        .byte    $1F,$7B,$75,$37,$73,$77,$77,$FF ; CHARACTER 134
        .byte    $BF,$5F,$7B,$75,$55,$59,$9D,$F3 ; CHARACTER 135
        .byte    $5F,$57,$57,$17,$53,$55,$55,$FF ; CHARACTER 136
        .byte    $1F,$BF,$BB,$BF,$BB,$BB,$1B,$FF ; CHARACTER 137
        .byte    $9F,$DF,$DF,$D9,$DD,$5D,$B5,$FB ; CHARACTER 138
        .byte    $5F,$57,$17,$35,$53,$53,$55,$FF ; CHARACTER 139
        .byte    $7F,$7B,$7B,$7B,$7B,$7B,$1B,$FF ; CHARACTER 140
        .byte    $5F,$1F,$15,$51,$51,$55,$55,$FF ; CHARACTER 141
        .byte    $5F,$5F,$1F,$13,$15,$55,$55,$FF ; CHARACTER 142
        .byte    $BF,$5F,$5B,$55,$55,$55,$BB,$FF ; CHARACTER 143
        .byte    $3F,$5F,$53,$55,$35,$73,$77,$F7 ; CHARACTER 144
        .byte    $BF,$5F,$5B,$55,$55,$19,$9D,$FC ; CHARACTER 145
        .byte    $3F,$5F,$5B,$55,$37,$57,$57,$FF ; CHARACTER 146
        .byte    $BF,$5B,$75,$B7,$DB,$5D,$BB,$FF ; CHARACTER 147
        .byte    $1F,$BB,$BB,$B1,$BB,$BB,$BB,$FF ; CHARACTER 148
        .byte    $5F,$5F,$55,$55,$55,$55,$99,$FF ; CHARACTER 149
        .byte    $5F,$5F,$55,$55,$55,$55,$BB,$FF ; CHARACTER 150
        .byte    $5F,$5F,$55,$55,$55,$11,$55,$FF ; CHARACTER 151
        .byte    $5F,$5F,$55,$B5,$5B,$55,$55,$FF ; CHARACTER 152
        .byte    $5F,$5F,$5F,$B5,$B5,$B9,$BD,$F3 ; CHARACTER 153
        .byte    $1F,$DF,$D1,$BD,$7B,$77,$11,$FF ; CHARACTER 154
        .byte    $11,$77,$77,$77,$77,$77,$11,$FF ; CHARACTER 155
        .byte    $DD,$BB,$BB,$11,$BB,$33,$55,$FF ; CHARACTER 156
        .byte    $11,$DD,$DD,$DD,$DD,$DD,$11,$FF ; CHARACTER 157
        .byte    $FF,$DD,$88,$DD,$DD,$DD,$DD,$DD ; CHARACTER 158
        .byte    $FF,$FF,$DD,$BB,$11,$BB,$DD,$FF ; CHARACTER 159
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 160
        .byte    $DD,$DD,$DD,$DD,$FF,$FF,$DD,$FF ; CHARACTER 161
        .byte    $55,$55,$55,$FF,$FF,$FF,$FF,$FF ; CHARACTER 162
        .byte    $BB,$BB,$11,$BB,$11,$BB,$BB,$FF ; CHARACTER 163
        .byte    $BB,$11,$33,$11,$99,$11,$BB,$FF ; CHARACTER 164
        .byte    $FF,$33,$33,$DD,$BB,$44,$CC,$FF ; CHARACTER 165
        .byte    $BB,$55,$55,$BB,$55,$66,$99,$FF ; CHARACTER 166
        .byte    $DD,$BB,$77,$FF,$FF,$FF,$FF,$FF ; CHARACTER 167
        .byte    $DD,$BB,$77,$77,$77,$BB,$DD,$FF ; CHARACTER 168
        .byte    $77,$BB,$DD,$DD,$DD,$BB,$77,$FF ; CHARACTER 169
        .byte    $FF,$BB,$11,$BB,$11,$BB,$FF,$FF ; CHARACTER 170
        .byte    $FF,$BB,$BB,$11,$BB,$BB,$FF,$FF ; CHARACTER 171
        .byte    $FF,$FF,$FF,$FF,$FF,$DD,$DD,$BB ; CHARACTER 172
        .byte    $FF,$FF,$FF,$11,$FF,$FF,$FF,$FF ; CHARACTER 173
        .byte    $FF,$FF,$FF,$FF,$FF,$33,$33,$FF ; CHARACTER 174
        .byte    $FF,$DD,$DD,$BB,$BB,$77,$77,$FF ; CHARACTER 175
        .byte    $BB,$11,$55,$55,$55,$11,$BB,$FF ; CHARACTER 176
        .byte    $BB,$33,$BB,$BB,$BB,$BB,$11,$FF ; CHARACTER 177
        .byte    $BB,$55,$DD,$BB,$77,$77,$11,$FF ; CHARACTER 178
        .byte    $BB,$55,$DD,$BB,$DD,$55,$BB,$FF ; CHARACTER 179
        .byte    $55,$55,$55,$11,$DD,$DD,$DD,$FF ; CHARACTER 180
        .byte    $11,$77,$77,$BB,$DD,$55,$BB,$FF ; CHARACTER 181
        .byte    $BB,$77,$33,$55,$55,$55,$BB,$FF ; CHARACTER 182
        .byte    $11,$DD,$DD,$BB,$BB,$BB,$BB,$FF ; CHARACTER 183
        .byte    $BB,$55,$55,$BB,$55,$55,$BB,$FF ; CHARACTER 184
        .byte    $BB,$55,$55,$99,$DD,$55,$BB,$FF ; CHARACTER 185
        .byte    $FF,$FF,$DD,$FF,$FF,$DD,$FF,$FF ; CHARACTER 186
        .byte    $FF,$FF,$DD,$FF,$FF,$DD,$DD,$BB ; CHARACTER 187
        .byte    $DD,$99,$33,$77,$33,$99,$DD,$FF ; CHARACTER 188
        .byte    $FF,$FF,$11,$FF,$11,$FF,$FF,$FF ; CHARACTER 189
        .byte    $77,$33,$99,$DD,$99,$33,$77,$FF ; CHARACTER 190
        .byte    $BB,$55,$DD,$BB,$BB,$FF,$BB,$FF ; CHARACTER 191
        .byte    $FF,$FF,$FF,$FF,$00,$FF,$FF,$FF ; CHARACTER 192
        .byte    $BB,$15,$15,$11,$15,$B5,$15,$FF ; CHARACTER 193
        .byte    $B3,$B5,$B5,$B3,$B5,$B5,$B3,$BF ; CHARACTER 194
        .byte    $FB,$F5,$F7,$07,$F7,$F5,$FB,$FF ; CHARACTER 195
        .byte    $F3,$F5,$05,$F5,$F5,$F5,$F3,$FF ; CHARACTER 196
        .byte    $F1,$07,$F7,$F3,$F7,$F7,$F1,$FF ; CHARACTER 197
        .byte    $F1,$F7,$F7,$F3,$F7,$07,$F7,$FF ; CHARACTER 198
        .byte    $BB,$B5,$B7,$B7,$B5,$B5,$B9,$BF ; CHARACTER 199
        .byte    $D5,$D5,$D5,$D1,$D5,$D5,$D5,$DF ; CHARACTER 200
        .byte    $F1,$FB,$FB,$7B,$BB,$DB,$D1,$DF ; CHARACTER 201
        .byte    $D1,$DB,$DB,$EB,$FB,$FB,$F7,$FF ; CHARACTER 202
        .byte    $D5,$D5,$D5,$B3,$73,$F5,$F5,$FF ; CHARACTER 203
        .byte    $77,$77,$77,$77,$77,$77,$71,$0F ; CHARACTER 204
        .byte    $75,$71,$B1,$B5,$D5,$D5,$E5,$EF ; CHARACTER 205
        .byte    $E5,$E5,$D5,$D1,$B1,$B5,$75,$7F ; CHARACTER 206
        .byte    $0B,$75,$75,$75,$75,$75,$7B,$7F ; CHARACTER 207
        .byte    $03,$E5,$E5,$E3,$E7,$E7,$E7,$EF ; CHARACTER 208
        .byte    $FB,$B5,$15,$15,$15,$11,$B9,$FE ; CHARACTER 209
        .byte    $F3,$F5,$F5,$F3,$F5,$F5,$05,$FF ; CHARACTER 210
        .byte    $9B,$05,$07,$0B,$9D,$D5,$FB,$FF ; CHARACTER 211
        .byte    $B1,$BB,$BB,$BB,$BB,$BB,$BB,$BF ; CHARACTER 212
        .byte    $F5,$F5,$F5,$F5,$F5,$E5,$D9,$DF ; CHARACTER 213
        .byte    $65,$65,$95,$95,$95,$65,$6B,$FF ; CHARACTER 214
        .byte    $F5,$B5,$55,$55,$51,$51,$B5,$FF ; CHARACTER 215
        .byte    $B5,$15,$AB,$4B,$AB,$B5,$B5,$FF ; CHARACTER 216
        .byte    $D5,$D5,$D5,$DB,$DB,$DB,$DB,$DF ; CHARACTER 217
        .byte    $B1,$1D,$0D,$0B,$07,$17,$B1,$FF ; CHARACTER 218
        .byte    $DD,$DD,$DD,$DD,$00,$DD,$DD,$DD ; CHARACTER 219
        .byte    $77,$BB,$77,$BB,$77,$BB,$77,$BB ; CHARACTER 220
        .byte    $DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD ; CHARACTER 221
        .byte    $F5,$FA,$E5,$9A,$15,$9A,$95,$FA ; CHARACTER 222
        .byte    $06,$8B,$8D,$C6,$CB,$CD,$E6,$EB ; CHARACTER 223
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 224
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 225
        .byte    $FF,$FF,$FF,$FF,$00,$00,$00,$00 ; CHARACTER 226
        .byte    $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 227
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00 ; CHARACTER 228
        .byte    $77,$77,$77,$77,$77,$77,$77,$77 ; CHARACTER 229
        .byte    $55,$AA,$55,$AA,$55,$AA,$55,$AA ; CHARACTER 230
        .byte    $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE ; CHARACTER 231
        .byte    $FF,$FF,$FF,$FF,$55,$AA,$55,$AA ; CHARACTER 232
        .byte    $0B,$16,$1D,$3B,$36,$3D,$7B,$76 ; CHARACTER 233
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 234
        .byte    $DD,$DD,$DD,$DD,$CC,$DD,$DD,$DD ; CHARACTER 235
        .byte    $FF,$FF,$FF,$FF,$CC,$CC,$CC,$CC ; CHARACTER 236
        .byte    $DD,$DD,$DD,$DD,$CC,$FF,$FF,$FF ; CHARACTER 237
        .byte    $FF,$FF,$FF,$FF,$11,$DD,$DD,$DD ; CHARACTER 238
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$00,$00 ; CHARACTER 239
        .byte    $FF,$FF,$FF,$FF,$CC,$DD,$DD,$DD ; CHARACTER 240
        .byte    $DD,$DD,$DD,$DD,$00,$FF,$FF,$FF ; CHARACTER 241
        .byte    $FF,$FF,$FF,$FF,$00,$DD,$DD,$DD ; CHARACTER 242
        .byte    $DD,$DD,$DD,$DD,$11,$DD,$DD,$DD ; CHARACTER 243
        .byte    $77,$77,$77,$77,$77,$77,$77,$77 ; CHARACTER 244
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 245
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 246
        .byte    $00,$00,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 247
        .byte    $00,$00,$00,$FF,$FF,$FF,$FF,$FF ; CHARACTER 248
        .byte    $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; CHARACTER 249
        .byte    $EF,$EE,$EE,$E5,$E5,$E3,$E7,$0F ; CHARACTER 250
        .byte    $FF,$FF,$FF,$FF,$33,$33,$33,$33 ; CHARACTER 251
        .byte    $CC,$CC,$CC,$CC,$FF,$FF,$FF,$FF ; CHARACTER 252
        .byte    $DD,$DD,$DD,$DD,$11,$FF,$FF,$FF ; CHARACTER 253
        .byte    $33,$33,$33,$33,$FF,$FF,$FF,$FF ; CHARACTER 254
        .byte    $33,$33,$33,$33,$CC,$CC,$CC,$CC ; CHARACTER 255
        .byte    $00,$44,$AA,$AA,$88,$88,$66,$00 ; CHARACTER 256
        .byte    $40,$A0,$A0,$E4,$AA,$AA,$A6,$00 ; CHARACTER 257
        .byte    $C0,$A8,$A8,$C8,$AC,$AA,$CC,$00 ; CHARACTER 258
        .byte    $40,$A0,$84,$8A,$88,$AA,$44,$00 ; CHARACTER 259
        .byte    $C0,$A2,$A2,$A2,$A6,$AA,$C6,$00 ; CHARACTER 260
        .byte    $E0,$80,$84,$CA,$8E,$88,$E6,$00 ; CHARACTER 261
        .byte    $E0,$84,$8A,$C8,$8C,$88,$88,$00 ; CHARACTER 262
        .byte    $40,$A0,$84,$8A,$AA,$A6,$62,$0C ; CHARACTER 263
        .byte    $A0,$A8,$A8,$E8,$AC,$AA,$AA,$00 ; CHARACTER 264
        .byte    $E0,$40,$44,$40,$44,$44,$E4,$00 ; CHARACTER 265
        .byte    $60,$20,$20,$26,$22,$A2,$4A,$04 ; CHARACTER 266
        .byte    $A0,$A8,$E8,$CA,$AC,$AC,$AA,$00 ; CHARACTER 267
        .byte    $80,$84,$84,$84,$84,$84,$E4,$00 ; CHARACTER 268
        .byte    $A0,$E0,$EA,$AE,$AE,$AA,$AA,$00 ; CHARACTER 269
        .byte    $A0,$A0,$E0,$EC,$EA,$AA,$AA,$00 ; CHARACTER 270
        .byte    $40,$A0,$A4,$AA,$AA,$AA,$44,$00 ; CHARACTER 271
        .byte    $C0,$A0,$AC,$AA,$CA,$8C,$88,$08 ; CHARACTER 272
        .byte    $40,$A0,$A4,$AA,$AA,$E6,$62,$03 ; CHARACTER 273
        .byte    $C0,$A0,$A4,$AA,$C8,$A8,$A8,$00 ; CHARACTER 274
        .byte    $40,$A4,$8A,$48,$24,$A2,$44,$00 ; CHARACTER 275
        .byte    $E0,$44,$44,$4E,$44,$44,$44,$00 ; CHARACTER 276
        .byte    $A0,$A0,$AA,$AA,$AA,$AA,$66,$00 ; CHARACTER 277
        .byte    $A0,$A0,$AA,$AA,$AA,$AA,$44,$00 ; CHARACTER 278
        .byte    $A0,$A0,$AA,$AA,$AA,$EE,$AA,$00 ; CHARACTER 279
        .byte    $A0,$A0,$AA,$4A,$A4,$AA,$AA,$00 ; CHARACTER 280
        .byte    $A0,$A0,$A0,$4A,$4A,$46,$42,$0C ; CHARACTER 281
        .byte    $E0,$20,$2E,$42,$84,$88,$EE,$00 ; CHARACTER 282
        .byte    $EE,$88,$88,$88,$88,$88,$EE,$00 ; CHARACTER 283
        .byte    $22,$44,$44,$EE,$44,$CC,$AA,$00 ; CHARACTER 284
        .byte    $EE,$22,$22,$22,$22,$22,$EE,$00 ; CHARACTER 285
        .byte    $00,$44,$EE,$44,$44,$44,$44,$44 ; CHARACTER 286
        .byte    $00,$00,$22,$44,$EE,$44,$22,$00 ; CHARACTER 287
        .byte    $00,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 288
        .byte    $44,$44,$44,$44,$00,$00,$44,$00 ; CHARACTER 289
        .byte    $AA,$AA,$AA,$00,$00,$00,$00,$00 ; CHARACTER 290
        .byte    $44,$44,$EE,$44,$EE,$44,$44,$00 ; CHARACTER 291
        .byte    $44,$EE,$CC,$EE,$66,$EE,$44,$00 ; CHARACTER 292
        .byte    $00,$CC,$CC,$22,$44,$BB,$33,$00 ; CHARACTER 293
        .byte    $44,$AA,$AA,$44,$AA,$99,$66,$00 ; CHARACTER 294
        .byte    $22,$44,$88,$00,$00,$00,$00,$00 ; CHARACTER 295
        .byte    $22,$44,$88,$88,$88,$44,$22,$00 ; CHARACTER 296
        .byte    $88,$44,$22,$22,$22,$44,$88,$00 ; CHARACTER 297
        .byte    $00,$44,$EE,$44,$EE,$44,$00,$00 ; CHARACTER 298
        .byte    $00,$44,$44,$EE,$44,$44,$00,$00 ; CHARACTER 299
        .byte    $00,$00,$00,$00,$00,$44,$44,$88 ; CHARACTER 300
        .byte    $00,$00,$00,$EE,$00,$00,$00,$00 ; CHARACTER 301
        .byte    $00,$00,$00,$00,$00,$CC,$CC,$00 ; CHARACTER 302
        .byte    $00,$22,$22,$44,$44,$88,$88,$00 ; CHARACTER 303
        .byte    $44,$EE,$AA,$AA,$AA,$EE,$44,$00 ; CHARACTER 304
        .byte    $44,$CC,$44,$44,$44,$44,$EE,$00 ; CHARACTER 305
        .byte    $44,$AA,$22,$44,$88,$88,$EE,$00 ; CHARACTER 306
        .byte    $44,$AA,$22,$44,$22,$AA,$44,$00 ; CHARACTER 307
        .byte    $AA,$AA,$AA,$EE,$22,$22,$22,$00 ; CHARACTER 308
        .byte    $EE,$88,$88,$44,$22,$AA,$44,$00 ; CHARACTER 309
        .byte    $44,$88,$CC,$AA,$AA,$AA,$44,$00 ; CHARACTER 310
        .byte    $EE,$22,$22,$44,$44,$44,$44,$00 ; CHARACTER 311
        .byte    $44,$AA,$AA,$44,$AA,$AA,$44,$00 ; CHARACTER 312
        .byte    $44,$AA,$AA,$66,$22,$AA,$44,$00 ; CHARACTER 313
        .byte    $00,$00,$44,$00,$00,$44,$00,$00 ; CHARACTER 314
        .byte    $00,$00,$44,$00,$00,$44,$44,$88 ; CHARACTER 315
        .byte    $22,$66,$CC,$88,$CC,$66,$22,$00 ; CHARACTER 316
        .byte    $00,$00,$EE,$00,$EE,$00,$00,$00 ; CHARACTER 317
        .byte    $88,$CC,$66,$22,$66,$CC,$88,$00 ; CHARACTER 318
        .byte    $44,$AA,$22,$44,$44,$00,$44,$00 ; CHARACTER 319
        .byte    $00,$00,$00,$00,$FF,$00,$00,$00 ; CHARACTER 320
        .byte    $44,$EA,$EA,$EE,$EA,$4A,$EA,$00 ; CHARACTER 321
        .byte    $4C,$4A,$4A,$4C,$4A,$4A,$4C,$40 ; CHARACTER 322
        .byte    $04,$0A,$08,$F8,$08,$0A,$04,$00 ; CHARACTER 323
        .byte    $0C,$0A,$FA,$0A,$0A,$0A,$0C,$00 ; CHARACTER 324
        .byte    $0E,$F8,$08,$0C,$08,$08,$0E,$00 ; CHARACTER 325
        .byte    $0E,$08,$08,$0C,$08,$F8,$08,$00 ; CHARACTER 326
        .byte    $44,$4A,$48,$48,$4A,$4A,$46,$40 ; CHARACTER 327
        .byte    $2A,$2A,$2A,$2E,$2A,$2A,$2A,$20 ; CHARACTER 328
        .byte    $0E,$04,$04,$84,$44,$24,$2E,$20 ; CHARACTER 329
        .byte    $2E,$24,$24,$14,$04,$04,$08,$00 ; CHARACTER 330
        .byte    $2A,$2A,$2A,$4C,$8C,$0A,$0A,$00 ; CHARACTER 331
        .byte    $88,$88,$88,$88,$88,$88,$8E,$F0 ; CHARACTER 332
        .byte    $8A,$8E,$4E,$4A,$2A,$2A,$1A,$10 ; CHARACTER 333
        .byte    $1A,$1A,$2A,$2E,$4E,$4A,$8A,$80 ; CHARACTER 334
        .byte    $F4,$8A,$8A,$8A,$8A,$8A,$84,$80 ; CHARACTER 335
        .byte    $FC,$1A,$1A,$1C,$18,$18,$18,$10 ; CHARACTER 336
        .byte    $04,$4A,$EA,$EA,$EA,$EE,$46,$01 ; CHARACTER 337
        .byte    $0C,$0A,$0A,$0C,$0A,$0A,$FA,$00 ; CHARACTER 338
        .byte    $64,$FA,$F8,$F4,$62,$2A,$04,$00 ; CHARACTER 339
        .byte    $4E,$44,$44,$44,$44,$44,$44,$40 ; CHARACTER 340
        .byte    $0A,$0A,$0A,$0A,$0A,$1A,$26,$20 ; CHARACTER 341
        .byte    $9A,$9A,$6A,$6A,$6A,$9A,$94,$00 ; CHARACTER 342
        .byte    $0A,$4A,$AA,$AA,$AE,$AE,$4A,$00 ; CHARACTER 343
        .byte    $4A,$EA,$54,$B4,$54,$4A,$4A,$00 ; CHARACTER 344
        .byte    $2A,$2A,$2A,$24,$24,$24,$24,$20 ; CHARACTER 345
        .byte    $4E,$E2,$F2,$F4,$F8,$E8,$4E,$00 ; CHARACTER 346
        .byte    $22,$22,$22,$22,$FF,$22,$22,$22 ; CHARACTER 347
        .byte    $88,$44,$88,$44,$88,$44,$88,$44 ; CHARACTER 348
        .byte    $44,$44,$44,$44,$44,$44,$44,$44 ; CHARACTER 349
        .byte    $0A,$05,$1A,$65,$EA,$65,$6A,$05 ; CHARACTER 350
        .byte    $F9,$74,$72,$39,$34,$32,$19,$14 ; CHARACTER 351
        .byte    $00,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 352
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 353
        .byte    $00,$00,$00,$00,$FF,$FF,$FF,$FF ; CHARACTER 354
        .byte    $FF,$00,$00,$00,$00,$00,$00,$00 ; CHARACTER 355
        .byte    $00,$00,$00,$00,$00,$00,$00,$FF ; CHARACTER 356
        .byte    $88,$88,$88,$88,$88,$88,$88,$88 ; CHARACTER 357
        .byte    $AA,$55,$AA,$55,$AA,$55,$AA,$55 ; CHARACTER 358
        .byte    $11,$11,$11,$11,$11,$11,$11,$11 ; CHARACTER 359
        .byte    $00,$00,$00,$00,$AA,$55,$AA,$55 ; CHARACTER 360
        .byte    $F4,$E9,$E2,$C4,$C9,$C2,$84,$89 ; CHARACTER 361
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 362
        .byte    $22,$22,$22,$22,$33,$22,$22,$22 ; CHARACTER 363
        .byte    $00,$00,$00,$00,$33,$33,$33,$33 ; CHARACTER 364
        .byte    $22,$22,$22,$22,$33,$00,$00,$00 ; CHARACTER 365
        .byte    $00,$00,$00,$00,$CC,$44,$44,$44 ; CHARACTER 366
        .byte    $00,$00,$00,$00,$00,$00,$FF,$FF ; CHARACTER 367
        .byte    $00,$00,$00,$00,$33,$22,$22,$22 ; CHARACTER 368
        .byte    $22,$22,$22,$22,$FF,$00,$00,$00 ; CHARACTER 369
        .byte    $00,$00,$00,$00,$FF,$22,$22,$22 ; CHARACTER 370
        .byte    $22,$22,$22,$22,$EE,$22,$22,$22 ; CHARACTER 371
        .byte    $88,$88,$88,$88,$88,$88,$88,$88 ; CHARACTER 372
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 373
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 374
        .byte    $FF,$FF,$00,$00,$00,$00,$00,$00 ; CHARACTER 375
        .byte    $FF,$FF,$FF,$00,$00,$00,$00,$00 ; CHARACTER 376
        .byte    $00,$00,$00,$00,$00,$FF,$FF,$FF ; CHARACTER 377
        .byte    $10,$11,$11,$1A,$1A,$1C,$18,$F0 ; CHARACTER 378
        .byte    $00,$00,$00,$00,$CC,$CC,$CC,$CC ; CHARACTER 379
        .byte    $33,$33,$33,$33,$00,$00,$00,$00 ; CHARACTER 380
        .byte    $22,$22,$22,$22,$EE,$00,$00,$00 ; CHARACTER 381
        .byte    $CC,$CC,$CC,$CC,$00,$00,$00,$00 ; CHARACTER 382
        .byte    $CC,$CC,$CC,$CC,$33,$33,$33,$33 ; CHARACTER 383
        .byte    $FF,$BB,$55,$55,$77,$77,$99,$FF ; CHARACTER 384
        .byte    $BF,$5F,$5F,$1B,$55,$55,$59,$FF ; CHARACTER 385
        .byte    $3F,$57,$57,$37,$53,$55,$33,$FF ; CHARACTER 386
        .byte    $BF,$5F,$7B,$75,$77,$55,$BB,$FF ; CHARACTER 387
        .byte    $3F,$5D,$5D,$5D,$59,$55,$39,$FF ; CHARACTER 388
        .byte    $1F,$7F,$7B,$35,$71,$77,$19,$FF ; CHARACTER 389
        .byte    $1F,$7B,$75,$37,$73,$77,$77,$FF ; CHARACTER 390
        .byte    $BF,$5F,$7B,$75,$55,$59,$9D,$F3 ; CHARACTER 391
        .byte    $5F,$57,$57,$17,$53,$55,$55,$FF ; CHARACTER 392
        .byte    $1F,$BF,$BB,$BF,$BB,$BB,$1B,$FF ; CHARACTER 393
        .byte    $9F,$DF,$DF,$D9,$DD,$5D,$B5,$FB ; CHARACTER 394
        .byte    $5F,$57,$17,$35,$53,$53,$55,$FF ; CHARACTER 395
        .byte    $7F,$7B,$7B,$7B,$7B,$7B,$1B,$FF ; CHARACTER 396
        .byte    $5F,$1F,$15,$51,$51,$55,$55,$FF ; CHARACTER 397
        .byte    $5F,$5F,$1F,$13,$15,$55,$55,$FF ; CHARACTER 398
        .byte    $BF,$5F,$5B,$55,$55,$55,$BB,$FF ; CHARACTER 399
        .byte    $3F,$5F,$53,$55,$35,$73,$77,$F7 ; CHARACTER 400
        .byte    $BF,$5F,$5B,$55,$55,$19,$9D,$FC ; CHARACTER 401
        .byte    $3F,$5F,$5B,$55,$37,$57,$57,$FF ; CHARACTER 402
        .byte    $BF,$5B,$75,$B7,$DB,$5D,$BB,$FF ; CHARACTER 403
        .byte    $1F,$BB,$BB,$B1,$BB,$BB,$BB,$FF ; CHARACTER 404
        .byte    $5F,$5F,$55,$55,$55,$55,$99,$FF ; CHARACTER 405
        .byte    $5F,$5F,$55,$55,$55,$55,$BB,$FF ; CHARACTER 406
        .byte    $5F,$5F,$55,$55,$55,$11,$55,$FF ; CHARACTER 407
        .byte    $5F,$5F,$55,$B5,$5B,$55,$55,$FF ; CHARACTER 408
        .byte    $5F,$5F,$5F,$B5,$B5,$B9,$BD,$F3 ; CHARACTER 409
        .byte    $1F,$DF,$D1,$BD,$7B,$77,$11,$FF ; CHARACTER 410
        .byte    $11,$77,$77,$77,$77,$77,$11,$FF ; CHARACTER 411
        .byte    $DD,$BB,$BB,$11,$BB,$33,$55,$FF ; CHARACTER 412
        .byte    $11,$DD,$DD,$DD,$DD,$DD,$11,$FF ; CHARACTER 413
        .byte    $FF,$BB,$11,$BB,$BB,$BB,$BB,$BB ; CHARACTER 414
        .byte    $FF,$FF,$DD,$BB,$11,$BB,$DD,$FF ; CHARACTER 415
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 416
        .byte    $BB,$BB,$BB,$BB,$FF,$FF,$BB,$FF ; CHARACTER 417
        .byte    $55,$55,$55,$FF,$FF,$FF,$FF,$FF ; CHARACTER 418
        .byte    $BB,$BB,$11,$BB,$11,$BB,$BB,$FF ; CHARACTER 419
        .byte    $BB,$11,$33,$11,$99,$11,$BB,$FF ; CHARACTER 420
        .byte    $FF,$33,$33,$DD,$BB,$44,$CC,$FF ; CHARACTER 421
        .byte    $BB,$55,$55,$BB,$55,$66,$99,$FF ; CHARACTER 422
        .byte    $DD,$BB,$77,$FF,$FF,$FF,$FF,$FF ; CHARACTER 423
        .byte    $DD,$BB,$77,$77,$77,$BB,$DD,$FF ; CHARACTER 424
        .byte    $77,$BB,$DD,$DD,$DD,$BB,$77,$FF ; CHARACTER 425
        .byte    $FF,$BB,$11,$BB,$11,$BB,$FF,$FF ; CHARACTER 426
        .byte    $FF,$BB,$BB,$11,$BB,$BB,$FF,$FF ; CHARACTER 427
        .byte    $FF,$FF,$FF,$FF,$FF,$BB,$BB,$77 ; CHARACTER 428
        .byte    $FF,$FF,$FF,$11,$FF,$FF,$FF,$FF ; CHARACTER 429
        .byte    $FF,$FF,$FF,$FF,$FF,$33,$33,$FF ; CHARACTER 430
        .byte    $FF,$DD,$DD,$BB,$BB,$77,$77,$FF ; CHARACTER 431
        .byte    $BB,$11,$55,$55,$55,$11,$BB,$FF ; CHARACTER 432
        .byte    $BB,$33,$BB,$BB,$BB,$BB,$11,$FF ; CHARACTER 433
        .byte    $BB,$55,$DD,$BB,$77,$77,$11,$FF ; CHARACTER 434
        .byte    $BB,$55,$DD,$BB,$DD,$55,$BB,$FF ; CHARACTER 435
        .byte    $55,$55,$55,$11,$DD,$DD,$DD,$FF ; CHARACTER 436
        .byte    $11,$77,$77,$BB,$DD,$55,$BB,$FF ; CHARACTER 437
        .byte    $BB,$77,$33,$55,$55,$55,$BB,$FF ; CHARACTER 438
        .byte    $11,$DD,$DD,$BB,$BB,$BB,$BB,$FF ; CHARACTER 439
        .byte    $BB,$55,$55,$BB,$55,$55,$BB,$FF ; CHARACTER 440
        .byte    $BB,$55,$55,$99,$DD,$55,$BB,$FF ; CHARACTER 441
        .byte    $FF,$FF,$BB,$FF,$FF,$BB,$FF,$FF ; CHARACTER 442
        .byte    $FF,$FF,$BB,$FF,$FF,$BB,$BB,$77 ; CHARACTER 443
        .byte    $DD,$99,$33,$77,$33,$99,$DD,$FF ; CHARACTER 444
        .byte    $FF,$FF,$11,$FF,$11,$FF,$FF,$FF ; CHARACTER 445
        .byte    $77,$33,$99,$DD,$99,$33,$77,$FF ; CHARACTER 446
        .byte    $BB,$55,$DD,$BB,$BB,$FF,$BB,$FF ; CHARACTER 447
        .byte    $FF,$FF,$FF,$FF,$00,$FF,$FF,$FF ; CHARACTER 448
        .byte    $BB,$15,$15,$11,$15,$B5,$15,$FF ; CHARACTER 449
        .byte    $B3,$B5,$B5,$B3,$B5,$B5,$B3,$BF ; CHARACTER 450
        .byte    $FB,$F5,$F7,$07,$F7,$F5,$FB,$FF ; CHARACTER 451
        .byte    $F3,$F5,$05,$F5,$F5,$F5,$F3,$FF ; CHARACTER 452
        .byte    $F1,$07,$F7,$F3,$F7,$F7,$F1,$FF ; CHARACTER 453
        .byte    $F1,$F7,$F7,$F3,$F7,$07,$F7,$FF ; CHARACTER 454
        .byte    $BB,$B5,$B7,$B7,$B5,$B5,$B9,$BF ; CHARACTER 455
        .byte    $D5,$D5,$D5,$D1,$D5,$D5,$D5,$DF ; CHARACTER 456
        .byte    $F1,$FB,$FB,$7B,$BB,$DB,$D1,$DF ; CHARACTER 457
        .byte    $D1,$DB,$DB,$EB,$FB,$FB,$F7,$FF ; CHARACTER 458
        .byte    $D5,$D5,$D5,$B3,$73,$F5,$F5,$FF ; CHARACTER 459
        .byte    $77,$77,$77,$77,$77,$77,$71,$0F ; CHARACTER 460
        .byte    $75,$71,$B1,$B5,$D5,$D5,$E5,$EF ; CHARACTER 461
        .byte    $E5,$E5,$D5,$D1,$B1,$B5,$75,$7F ; CHARACTER 462
        .byte    $0B,$75,$75,$75,$75,$75,$7B,$7F ; CHARACTER 463
        .byte    $03,$E5,$E5,$E3,$E7,$E7,$E7,$EF ; CHARACTER 464
        .byte    $FB,$B5,$15,$15,$15,$11,$B9,$FE ; CHARACTER 465
        .byte    $F3,$F5,$F5,$F3,$F5,$F5,$05,$FF ; CHARACTER 466
        .byte    $9B,$05,$07,$0B,$9D,$D5,$FB,$FF ; CHARACTER 467
        .byte    $B1,$BB,$BB,$BB,$BB,$BB,$BB,$BF ; CHARACTER 468
        .byte    $F5,$F5,$F5,$F5,$F5,$E5,$D9,$DF ; CHARACTER 469
        .byte    $65,$65,$95,$95,$95,$65,$6B,$FF ; CHARACTER 470
        .byte    $F5,$B5,$55,$55,$51,$51,$B5,$FF ; CHARACTER 471
        .byte    $B5,$15,$AB,$4B,$AB,$B5,$B5,$FF ; CHARACTER 472
        .byte    $D5,$D5,$D5,$DB,$DB,$DB,$DB,$DF ; CHARACTER 473
        .byte    $B1,$1D,$0D,$0B,$07,$17,$B1,$FF ; CHARACTER 474
        .byte    $DD,$DD,$DD,$DD,$00,$DD,$DD,$DD ; CHARACTER 475
        .byte    $77,$BB,$77,$BB,$77,$BB,$77,$BB ; CHARACTER 476
        .byte    $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB ; CHARACTER 477
        .byte    $F5,$FA,$E5,$9A,$15,$9A,$95,$FA ; CHARACTER 478
        .byte    $06,$8B,$8D,$C6,$CB,$CD,$E6,$EB ; CHARACTER 479
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 480
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 481
        .byte    $FF,$FF,$FF,$FF,$00,$00,$00,$00 ; CHARACTER 482
        .byte    $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 483
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00 ; CHARACTER 484
        .byte    $77,$77,$77,$77,$77,$77,$77,$77 ; CHARACTER 485
        .byte    $55,$AA,$55,$AA,$55,$AA,$55,$AA ; CHARACTER 486
        .byte    $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE ; CHARACTER 487
        .byte    $FF,$FF,$FF,$FF,$55,$AA,$55,$AA ; CHARACTER 488
        .byte    $0B,$16,$1D,$3B,$36,$3D,$7B,$76 ; CHARACTER 489
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 490
        .byte    $DD,$DD,$DD,$DD,$CC,$DD,$DD,$DD ; CHARACTER 491
        .byte    $FF,$FF,$FF,$FF,$CC,$CC,$CC,$CC ; CHARACTER 492
        .byte    $DD,$DD,$DD,$DD,$CC,$FF,$FF,$FF ; CHARACTER 493
        .byte    $FF,$FF,$FF,$FF,$33,$BB,$BB,$BB ; CHARACTER 494
        .byte    $FF,$FF,$FF,$FF,$FF,$FF,$00,$00 ; CHARACTER 495
        .byte    $FF,$FF,$FF,$FF,$CC,$DD,$DD,$DD ; CHARACTER 496
        .byte    $DD,$DD,$DD,$DD,$00,$FF,$FF,$FF ; CHARACTER 497
        .byte    $FF,$FF,$FF,$FF,$00,$DD,$DD,$DD ; CHARACTER 498
        .byte    $DD,$DD,$DD,$DD,$11,$DD,$DD,$DD ; CHARACTER 499
        .byte    $77,$77,$77,$77,$77,$77,$77,$77 ; CHARACTER 500
        .byte    $33,$33,$33,$33,$33,$33,$33,$33 ; CHARACTER 501
        .byte    $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC ; CHARACTER 502
        .byte    $00,$00,$FF,$FF,$FF,$FF,$FF,$FF ; CHARACTER 503
        .byte    $00,$00,$00,$FF,$FF,$FF,$FF,$FF ; CHARACTER 504
        .byte    $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; CHARACTER 505
        .byte    $EF,$EE,$EE,$E5,$E5,$E3,$E7,$0F ; CHARACTER 506
        .byte    $FF,$FF,$FF,$FF,$33,$33,$33,$33 ; CHARACTER 507
        .byte    $CC,$CC,$CC,$CC,$FF,$FF,$FF,$FF ; CHARACTER 508
        .byte    $DD,$DD,$DD,$DD,$11,$FF,$FF,$FF ; CHARACTER 509
        .byte    $33,$33,$33,$33,$FF,$FF,$FF,$FF ; CHARACTER 510
        .byte    $33,$33,$33,$33,$CC,$CC,$CC,$CC ; CHARACTER 511
