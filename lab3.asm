assume cs:code, ds:data

data segment
string db 100, 101 dup(0)
null_msg db 'NULL', '$'
data ends

; Реализация функции strchr
; Функция strchr выполняет поиск первого вхождения символа symbol в строку string. 
; Возвращает указатель на первое вхождение символа в строке, если его нет - нулевой указатель.

code segment
strchr proc
    push bp
    mov bp, sp

    mov bx, [bp+4] ; загрузка символа, bl = символ

    mov si, [bp+6] ; загрузим оффсет буффера строки
    inc si
    mov ch, [si] ; ch = длина строки
    inc si
    xor cl, cl

    compare_loop:
        inc cl
	mov al, [si] ; загрузили из [si] в al символ
        cmp al, bl
        je done

        cmp cl, ch ; если достигнут конец строки
        je fail
	inc si
        jmp compare_loop

    fail:
        mov si, -1 ; вернуть нулевой указатель

    done:
        pop bp
        pop bx ; bx = адрес return
        push si ; пушим указатель
        push bx ; пушим адрес return
        ret
strchr endp


start:
    mov ax, data
    mov ds, ax

    ; ввод строки
    mov dx, offset string
    mov ah, 0Ah
    int 21h
    push dx

    mov dl, 10 ; переход на новую строку
    mov ah, 02h
    int 21h

    ; ввод символа
    mov ah, 01h
    int 21h
    push ax

    mov dl, 10 ; переход на новую строку
    mov ah, 02h
    int 21h

    call strchr
    pop ax ; достаем результат работы strchr
    mov si, ax
    cmp si, -1 ; проверка на нулевой указатель
    je is_null
    
; вывод символа по указателю
    mov al, [si] ; загрузка из укзателя
    mov ah, 0
    mov dl, al 
    mov ah, 02h 
    int 21h

    jmp exit

is_null:
    mov dx, offset null_msg 
    mov ah, 09h
    int 21h

exit:
    mov ax, 4c00h
    int 21h
code ends
end start