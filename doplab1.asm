assume CS:code, DS:data

data segment
    a db 30
    b db 1
    c db 15
    d db 15
    res10 db 3 dup(), 10, '$'
    res16 db 2 dup(), '$'
data ends

code segment
start:
    mov AX, data
    mov DS, AX
    mov AX, 0h 

    ; (8*a) / b
    mov CL, 3 
    mov AL, a
    shl AL, CL
    mov BL, b
    div BL

    ; (c+d)/2
    mov CL, c
    add CL, d
    shr CL, 1
    add AX, CX
    mov CX, AX

    ; перевод в десятичную систему
    mov BL, 10
    mov SI, 2
convert_loop_10:
    mov AH, 00h
    div BL
    mov res10[SI], AH
    add res10[SI], '0'
    dec SI
    cmp AL, 0
    jne convert_loop_10

    ; вывод в десятичной системе
    mov DX, offset res10
    mov AH, 09h
    int 21h

    ; перевод в шестнадцатиричную систему
    mov AX, CX
    mov BL, 16
    mov SI, 1
convert_loop_16:
    mov AH, 00h
    div BL
    cmp AH, 10
    jl digit
    jnle symbol
digit:
    add AH, '0'
    jmp continue
symbol:
    add AH, 55
continue:
    mov res16[SI], AH
    dec SI
    cmp AL, 0
    jne convert_loop_16

    ; вывод в шестнадцатиричной системе
    mov DX, offset res16
    mov AH, 09h
    int 21h
    
    mov AX, 4C00h
    int 21h
code ends
end start
