include macro.asm

assume cs:code, ds:data

data segment
string db 100, 101 dup('$')
symbol db 100, 101 dup('$')
data ends

code segment

start:
    mov ax, data
    mov ds, ax

    input string

    input symbol

    solution string symbol   
    
    print string

exit:
    mov ax, 4c00h
    int 21h
code ends
end start
