nolist

; ===== Data Precs Sines =====

init_base_sine:
	ld hl,basesinedata
	ld bc,basesine
	ld de,basesine+127
	exx
	ld bc,basesine+128
	ld de,basesine+255
	exx

	ld ixl,64
	loop_sine_make:
		ld a,(hl):inc hl
		sub 129 ; we did a hack where we sub 128
			; to bring sine from 0-255 (where 128 was origin Y) to -128 to 127 space.

		ld (bc),a:inc c
		ld (de),a:dec e

		exx
		ld l,a:ld a,255:sub l
		ld (bc),a:inc c
		ld (de),a:dec e
		exx

	dec ixl
	jr nz,loop_sine_make
ret
