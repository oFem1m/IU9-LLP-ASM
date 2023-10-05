assume CS:code, DS:data

data segment
arr dw 0, 1, 2, 3
element dw 0
data ends

code segment
start:
    mov AX, data
    mov DS, AX
    mov AH, 00h      

    mov SI, 0
search:
    mov AX, arr[SI]
    cmp AX, element
    je success
    add SI, 2
    loop search

success:
    mov AH, 02h
    mov DL, [SI]
    add DL, '0'
    int 21h

    mov AH, 4Ch
    int 21h
code ends
end start
