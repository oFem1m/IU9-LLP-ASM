assume CS:code, DS:data

data segment
a db 1
b db 2
c db 4
d db 4
result db 0
data ends

code segment
start:
mov AX, data
mov DS, AX
mov AH, 00h      

; (8*a) / b
mov CL, 3 
mov AL, [a]
shl AL, CL
mov BL, [b]
div BL
mov [result], AL

; (c+d)/2 
mov AL, [c]
add AL, [d]
shr AL, 1
add [result], AL

; Вывод
mov AH, 02h
mov DL, [result]
add DL, '0'
int 21h

mov AH, 4Ch
int 21h

code ends
end start

