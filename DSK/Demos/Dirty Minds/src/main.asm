nolist

vbufferOffsetX EQU 0

main:
	xor a:call &bc0e
	call disable_ints

	call change_width

	call init_vram
	call init_render_unroll
	call init_base_sine

	ld sp,0
	call cls
	call demo_run

axisX:
dw 0,0,0
axisY:
dw 0,0,0
axisZ:
dw 0,0,0

demo_run:
	frame:
		call wait4vsync

		call script

		ld hl,(render_page_lines)
		ld de,TILES_LINE1
		call render_tilebuffer_to_screen

		ld hl,(nframe): ld a,l:inc hl: ld (nframe),hl
		and 1:call swapPage
	jr frame
swapPage:
	ld a,l:	and 1
	jr nz,show_page0
		call select_page_C000
		ld hl,VRAMLINES_8000 + vbufferOffsetX
	jr not_show_page0
	show_page0:
		call select_page_8000
		ld hl,VRAMLINES_C000 + vbufferOffsetX
	not_show_page0:

	ld (render_page_lines),hl
ret

nframe:
dw 0

sp_save:
dw 0

render_page_lines:
dw VRAMLINES_C000 + vbufferOffsetX

script:
	;;ld c,0:ld b,0:call plot
	;;ld c,63:ld b,0:call plot
	;;ld c,0:ld b,55:call plot
	;;ld c,63:ld b,55:call plot
	
	ld c,32:ld b,28:call plot

	ld iyh,7
xanaxana:
	ld a,iyh:add a:add a:add a:add a:add a:ld iyl,a
	ld a,(nframe):ld b,a:add a:add b:add iyl
	ex af,af':ld a,(nframe):add a:add a:add b:add iyl:ex af,af'
	call rotateAxes

	ld ixl,12
	xana:
	ld hl,axisX:call drawAxis
	ld hl,axisY:call drawAxis
	ld hl,axisZ:call drawAxis
	dec ixl
	jr nz,xana

	dec iyh
	jr nz,xanaxana
ret

drawAxis:
	ld e,(hl):inc l:ld d,(hl):inc l
	ex de,hl

	ld a,ixl
	add hl,hl:add hl,hl
	ld b,h:ld c,l
looperi1:
	add hl,bc
	dec a
	jr nz,looperi1

	ld bc,32*256:add hl,bc

	ex de,hl:ld ixh,d
	ld e,(hl):inc l:ld d,(hl):inc l
	ex de,hl

	ld a,ixl
	add hl,hl:add hl,hl
	ld b,h:ld c,l
looperi2:
	add hl,bc
	dec a
	jr nz,looperi2


	ld bc,28*256:add hl,bc
	ld c,ixh
	ld a,VHEIGHT:sub h
	ld b,a

	call plot
ret

plot:
	ld hl,VBUFFER1
	add hl,bc
	ld (hl),240
	
ret
