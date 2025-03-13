nolist

; ===== CPC General functions =====

; ---- Clear Screen ----
; Assuming we have two screen pages at &8000 and &C000
; Changes HL, DE, BC

cls:
	ld hl,&8000:ld de,&8001:ld bc,16384+15999:ld (hl),0:ldir
ret

; ---- Disable Interrupts ----
; Changes HL

disable_ints:
	di:ld hl,&c9fb:ld (&38),hl
ret

wait4vsync:
	ld b,&f5
	vsync0:
		in a,(c)
		rra
	jr c,vsync0
	ld b,&f5
	vsync1:
		in a,(c)
		rra
	jr nc,vsync1
ret
