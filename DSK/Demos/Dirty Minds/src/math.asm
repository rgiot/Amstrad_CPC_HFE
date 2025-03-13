nolist

mul_signed8x16_shr8:
; A = mul1(signed), DE = mul2(signed)
; result = A + HL
; then AHL >> 8 -> HL
;	push de		; keep mul2 for hack 3 down

	ld ixh,a	; save temporary
	bit 7,a		; check A sign
	jr z,no_neg_signA
            neg
	    dec a	; stupid hack 1, it comes from 01h to 80h, so the incoming add to bring it to 0-255 space overflows at 256
	no_neg_signA:

	add a		; stupid hack, 0-127 is now almost all the range 0-254 (to remain 99% normalized when >> 8)
			; yes, not a generic mul, just hack to match my preferences
	or a
	jr z,nohack2
	inc a		; stupidest hacks ever, to have it from 0 to 255, with a little skip, there are more coming
nohack2:

        ;;scf:ccf	; ???
        ld b,d		; save temporary
        bit 7,d		; check D sign
        jr z,no_neg_sign2a
            ld hl,65536
            sbc hl,de
            ex de,hl
        no_neg_sign2a:

        ld hl,0
        ld c,0

        add a,a
        jr nc,mul_816_0
            ld h,d
            ld l,e
        mul_816_0:

	ld ixl,7
	sevenBits:
	        add hl,hl
	        rla
	        jr nc,mul_816_1
	            add hl,de
	            adc a,c
	        mul_816_1:
	dec ixl
	jr nz,sevenBits

;	pop de
;	bit 7,d
;	jr nz,hackoff
;	add hl,de	; hack 3 so that mul2 * 255 is mul2 * 256, so that >> 8 at maximum will be 100% the val and not (255/256)%
			; that was to avoid going for a 16bit * 16bit mul just for the 256th value from 0 to 256
;hackoff:


        ld l,h
        ld h,a

        ;;scf:ccf	; ???
	ld a,ixh:xor b
        bit 7,a		; check D sign
        jr z,no_neg_sign2b
            ex de,hl
            ld hl,65536
            sbc hl,de
        no_neg_sign2b:
ret