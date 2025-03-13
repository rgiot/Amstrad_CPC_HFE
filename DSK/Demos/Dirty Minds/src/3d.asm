nolist

xazoNeg:
;;scf:ccf
bit 7,a
jr z,nomin
	ld a,&FF
	ret
nomin:
	xor a
ret

rotateAxes:
; A  = angleAroundY
; A' = angleAroundX

ld b,basesine/256
ld d,b
ld c,a			; (BC) = sin(a)
ld a,64:add c:ld e,a	; (DE) = cos(a)

; First rotation around Y
; -----------------------

;Rotate AxisX (1 0 0)
ld hl,axisX
ld a,(de):ld (hl),a:inc l:call xazoNeg:ld (hl),a:inc l		; Xx = cos(a)
;;ld (hl),a:inc l:ld (hl),a:inc l				; Xy = 0
inc l:inc l
ld a,(bc):ld (hl),a:inc l:call xazoNeg:ld (hl),a:inc l		; Xz = sin(a)

;Rotate AxisY (0 1 0)
xor a:ld (hl),a:inc l:ld (hl),a:inc l				; Yx = 0
;;ld a,127:ld (hl),a:inc l:xor a:ld (hl),a:inc l		; Yy = 127 (max trigonometric value)
inc l:inc l
ld (hl),a:inc l:ld (hl),a:inc l					; Yz = 0

;Rotate AxisZ (0 0 1)
ld a,(bc):ld (hl),a:inc l:call xazoNeg:ld (hl),a:inc l		; Zx = sin(a)
;;ld (hl),a:inc l:ld (hl),a:inc l				; Zy = 0
inc l:inc l
ld a,(de):neg:ld (hl),a:inc l:call xazoNeg:ld (hl),a		; Zz = -cos(a)

; Second rotation around X
; ------------------------

ex af,af'
ld c,a			; (BC) = sin(a')
ld a,64:add c:ld e,a	; (DE) = cos(a')

; Possibly the three Y' fills will comment out. Possibly 3 muls. And only affect y'
; y' = z*sin(a) - y*cos(a)

;Rotate AxisY
; Yy = -cos(a)
ld hl,axisY+2
ld a,(de):neg:ld (hl),a:inc l:call xazoNeg:ld (hl),a

;Rotate AxisX
; Xy = AxisX_z * sin(a)
ld hl,axisX+4
ld a,(bc):ld iyl,a	; store (BC) value to IYL because BC will be altered by mul
ld e,(hl):inc l:ld d,(hl)
call mul_signed8x16_shr8	; HL = A * DE
ex de,hl:ld hl,axisX+2:ld (hl),e:inc l:ld (hl),d

;Rotate AxisZ
; Zy = AxisZ_z * sin(a)
ld hl,axisZ+4
ld a,iyl		; restore IYL
ld e,(hl):inc l:ld d,(hl)
call mul_signed8x16_shr8	; HL = A * DE
ex de,hl:ld hl,axisZ+2:ld (hl),e:inc l:ld (hl),d

ret

