nolist

run &1C00
org &1C00

read "main.asm"
read "system.asm"
read "graphics.asm"
read "data.asm"
read "sineprecs.asm"
read "math.asm"
read "3d.asm"

list
thend:
nolist

org &700
basesine:
