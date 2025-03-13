nolist

VRAMLINES_C000 equ &0300
VRAMLINES_8000 equ &0400

TILES_LINE1 equ &0500
TILES_LINE2 equ &0600

VBUFFER1 equ &2020

UNROLL_SPACE equ &7000

VWIDTH equ 64
VHEIGHT equ 56

; ===== CPC Graphics functions =====

render_unroll_start:
        ld a,(hl):ld e,a:srl a:ld (hl),a:inc l
	ld a,(de):inc d:ld (bc),a:ld a,(de):set 3,b:ld (bc),a:inc c

        ld a,(hl):ld e,a:srl a:ld (hl),a:inc l
	ld a,(de):dec d:ld (bc),a:ld a,(de):res 3,b:ld (bc),a:inc c

render_unroll_end:
render_unroll_jump_start:
	jp render_unroll_back
render_unroll_jump_end:

init_render_unroll:
	ld de,UNROLL_SPACE
	ld a,VWIDTH/2
	init_render_unroll_loop:
		ld hl,render_unroll_start
		ld bc,render_unroll_end - render_unroll_start
		ldir
	dec a
	jr nz,init_render_unroll_loop

	ld hl,render_unroll_jump_start
	ld bc,render_unroll_jump_end - render_unroll_jump_start
	ldir
ret

render_tilebuffer_to_screen:
; de = tile_buffer		(e.g. TILES_LINE1)
; hl = vram_lines		(e.g. VRAMLINES_C000)

    ld (sp_save),sp

    ld sp,hl
    ld hl,VBUFFER1

    ld iy,VHEIGHT;
    tile_lines48:
        pop bc:;;exx:pop bc:exx

	jp UNROLL_SPACE
	render_unroll_back:

	ld a,l:sub VWIDTH:ld l,a:inc h

    dec iyl
    jp nz,tile_lines48

    ld sp,(sp_save)
ret

generate_vram64:
	ld b,25
	rows25:
		ld c,4
		lines8:
			ld (hl),e:inc hl:ld (hl),d:inc hl
			ld a,d:add 16:ld d,a
		dec c
		jr nz,lines8
	ld a,d:sub 64:ld d,a
	ld a,e:add 64:jr nc,no256
	inc d
	no256:
	ld e,a
	dec b
	jr nz,rows25
ret

tile_copy_routine:
	ld hl,chars0:ld de,TILES_LINE1

ld a,64
copy_char:
	ld ixl,7
	copy_char_times:
		ldi:dec hl
	dec ixl
	jr nz,copy_char_times

	ldi
dec a
jr nz,copy_char
ret

init_vram:
	ld de,&C000+256: ld hl,VRAMLINES_C000: call generate_vram64
	ld de,&8000+256: ld hl,VRAMLINES_8000: call generate_vram64

	call tile_copy_routine

	call palchange
ret

select_page_8000:
	ld bc,&bc0c:out (c),c
	ld bc,&bd20:out (c),c
ret

select_page_C000:
	ld bc,&bc0c:out (c),c
	ld bc,&bd30:out (c),c
ret

; ---- Change Width ----
; E = width (in bytes)
; E not used currently

change_width:
    ld bc,&bc01:out(c),c
;;    inc b:ld a,e:rra:ld c,a:out (c),c
	inc b:ld c,&20:out (c),c

;;    ld a,80:sub e:jr c,no_center
;;    rra:rra:ld d,a
;;    ld a,46:sub d:ld d,a

;;    ld bc,&bc02:out(c),c:inc b:ld c,d:out(c),c
    ld bc,&bc02:out(c),c:inc b:ld c,&2a:out(c),c

	ld bc,&bc06:out (c),c
	inc b:ld c,22:out (c),c
;;	ld bc,&bc07:out(c),c:inc b:ld c,30:out (c),c
    no_center:
ret

palchange:
	xor a
	ld hl,pal1
	ld b,&7f
	palchangeloop:
		ld c,a
		out (c),c
		ld c,(hl):out (c),c
		inc hl
	inc a
	cp 17
	jr nz,palchangeloop
ret

pal1:
db &54,&44,&44,&55
db &5d,&57,&5f,&5f
db &42,&42,&59,&59
db &59,&43,&43,&4b,&5d

;db &54,&44,&55,&5c
;db &58,&5d,&4c,&45
;db &4d,&56,&46,&57
;db &5e,&40,&5f,&4e
;db &47,&4f,&52,&42
;db &53,&5a,&59,&5b
;db &4a,&43,&4b