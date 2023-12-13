input macro string

	xor ax, ax
	mov ah, 0ah
	lea dx, string
	int 21h

    mov dl, 10 ; переход на новую строку
    mov ah, 02h
    int 21h

endm

print macro string

    xor ax, ax
    lea dx, string + 2
	mov ah, 09h
	int 21h

    mov dl, 10 ; переход на новую строку
    mov ah, 02h
    int 21h

endm

solution macro string, symbol 
    local compare_loop, success, swap_loop, end_macro
    mov si, offset string
    inc si
    mov ch, [si] 
    inc si
    mov di, offset symbol
    add di, 2
    mov bl, [di]

    xor cl, cl

    compare_loop:
        inc cl
	    mov al, [si] ; загрузить символ из [si] в al 
        cmp al, bl
        je success

        cmp cl, ch ; если достигнут конец строки
        je end_macro
	    inc si
        jmp compare_loop

    success:
        xor ax, ax
        cmp cl, 1
            je end_macro
        swap_loop:
            mov al, [si]      ; Загрузить символ, на который указывает si, в al
            mov ah, [si - 1]  ; Загрузить соседний слева символ в ah
            mov [si - 1], al   ; Записать символ из al в ячейку, на которую указывает si - 1
            mov [si], ah      ; Записать символ из ah в ячейку, на которую указывает si
            dec si            ; Уменьшить указатель на текущий символ
            dec cl
            jmp success
    end_macro:
endm