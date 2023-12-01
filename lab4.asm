assume cs: code, ds: data

data segment
    dummy db 0Ah, "$"
    string db 100, 99 dup ('$')
    max_len dw 16
    num1 db 100, 99 dup (0)
    num2 db 100, 99 dup (0)
    result db 100, 99 dup (0)
    set_radix db 0
    operation db 0
    cmpres db 0

    ; Сообщения
    prompt_radix db 100, " Choose radix (1 or 2):", 0dh, 0ah, "1. 10", 0dh, 0ah, "2. 16$"
    prompt_operation db 100, " Enter operation (+, -, *):$"
    prompt_numbers db 100, " Enter two numbers:$"
    error_bad_symbol db 100, " Error: bad symbol$"
data ends

code segment

; Макросы для ввода и вывода данных

scanstr macro string
    mov dx, offset string
    xor ax, ax
    mov ah, 0Ah
    int 21h
    mov si, dx
    xor bh, bh
    mov bl, [si+1]
    mov ch, '$'
    add bx, 2
    mov [si+bx], ch
    mov dx, offset dummy
    mov ah, 09h
    int 21h
endm

scannum macro num
    scanstr string
    mov dx, offset num
    push dx
    call tonum
endm

scanchar macro char
    mov ah, 01h
    int 21h
    mov char, al
    mov dl, 10 
    mov ah, 02h
    int 21h
endm

print macro str
    push ax
    mov ah, 09h
    lea dx, str
    add dx, 2 
    int 21h
    pop ax
endm

println macro str
    print str
    push ax
    mov ah, 09h
    lea dx, dummy
    int 21h
    pop ax
endm

printchar macro char
    push ax
    push dx
    mov ah, 2
    mov dl, char
    int 21h
    pop dx
    pop ax
endm

; Макросы для конвертации чисел и выполнения логических операций

tostring macro num, output_string
    push ax
    push bx
    push cx
    push di
    mov ax, num
	mov di, 4 
	mov cx, 5 
	MOV BL,10
	mov output_string[5], 10
	mov output_string[6], 13

	goto:
		DIV BL 
		mov output_string[di], ah
		add output_string[di],"0"
		mov ah,0
		sub di,1 
	loop goto
    pop di
    pop cx
    pop bx
    pop ax
endm

invert_sign macro num
    push di
    push ax
    mov di, max_len
    mov al, num[di]
    not al
    mov num[di], al
    pop ax
    pop di
endm

if_less macro a, b, endmark
    cmp a, b
    jge endmark
endm

if_not_number macro symbol, endmark
    push ax
    mov al, '/'
    mov ah, '0'
    add ah, set_radix
    if_less symbol, ah, _&endmark
    if_less al, symbol, _&endmark
        pop ax
        jmp endmark
    _&endmark&:   
    pop ax
endm

if_not_minus macro symbol, endmark
    push ax
    push bx
    mov ah, '-'
    mov bh, symbol
    cmp bh, ah
    pop bx
    pop ax
    je endmark
endm

; Процедуры конвертации в системы счисления и типы данных

tohex proc
    mov cl, 60h
    if_less cl, ch, tohexendif
        sub ch, 'a'
        add ch, ':'

    tohexendif:
    ret
tohex endp

fromhex proc
    mov cl, '9'
    if_less cl, ch, fromhexendif
        sub ch, ':'
        add ch, 'a'

    fromhexendif:
    ret
fromhex endp

numtostring proc
    mov bp, sp
    mov si, [bp + 2] 
    mov ax, max_len
    xor di, di 
    add si, max_len
    mov bl, [si]
    cmp bx, 0
    je plus
        printchar '-'
        jmp endsign

    plus:
        printchar '+'

    endsign:
    sub si, max_len
    mov bx, 2

    loop_numtostring:
        mov ch, [si]
        add ch, '0'
        call fromhex
        mov string[bx], ch

        inc si
        inc di
        inc bx
        if_less di, ax, break_numtostring
            jmp loop_numtostring

        break_numtostring:
    ret
numtostring endp

tonum proc
    mov bp, sp
    mov di, [bp + 2] 
    xor ax, ax
    mov al, string[1] 
    mov bx, max_len
    sub bx, ax  
    add ax, 2
    mov si, 2 
    xor dx, dx
    mov [di], dx

    loop_tonum:
        mov ch, string[si]
        call tohex
        if_not_number ch, ok_it_is_number
        if_not_minus ch, minus_case
            print error_bad_symbol
            jmp endprogram

        ok_it_is_number:
        jmp number_case

        minus_case:
            push ax
            add di, max_len
            mov ax, [di]
            not ax
            mov [di], ax
            sub di, max_len
            pop ax
            jmp endcase

        number_case:
            sub ch, '0'
            mov [di + bx], ch

        endcase:
        inc si
        inc bx
        if_less si, ax, break_tonum
            jmp loop_tonum

        break_tonum:
    ret
tonum endp

; Процедуры для работы с числами

swap_nums proc
    push si
    push ax
    push bx
    mov si, max_len 
    dec si

    loop_swap:
        mov al, num1[si]
        mov bl, num2[si]
        mov num1[si], bl
        mov num2[si], al
        dec si
        cmp si, 0
        je break_swap
        jmp loop_swap

    break_swap:    
    pop bx
    pop ax
    pop si
    ret
swap_nums endp

compare_nums proc
    push di
    push ax
    push bx    
    xor ax, ax
    xor bx, bx
    xor si, si
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]
    cmp ax, bx
    je loop_comp
    jl sign_less
        mov cmpres, 2        
        jmp endcompare_nums

    sign_less:
        mov cmpres, 1
        jmp endcompare_nums

    loop_comp:
        mov al, num1[si]
        mov bl, num2[si]
        cmp ax, bx
        je cmp_equal
        jl equal_less
            mov cmpres, 1
            jmp break_comp

        equal_less:
            mov cmpres, 2
            jmp break_comp

        cmp_equal:
        inc si
        cmp si, max_len
        jge break_comp
        jmp loop_comp

    break_comp:
    endcompare_nums:
    pop bx
    pop ax
    pop di
    ret
compare_nums endp

; Процедуры выполнения операций (сложение, вычитание, умножение)

count_sum proc
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]
    cmp al, bl
    je skipdiff
        invert_sign num2
        call count_diff
        ret

    skipdiff:
    call compare_nums
    cmp cmpres, 2
    jne not_swap_
        call swap_nums

    not_swap_:
    mov di, max_len
    mov al, num1[di]
    cmp al, 0
    je invert_sign_in_diff_
        invert_sign result

    invert_sign_in_diff_:
    mov si, max_len
    sub si, 1

    loop_sum:
        xor cx, cx
        mov ah, num1[si]
        mov bh, num2[si]
        mov ch, result[si]
        add ch, ah
        add ch, bh
        mov cl, set_radix
        dec cl
        if_less cl, ch, sum_overflow
            sub ch, set_radix
            mov cl, 1
            mov result[si - 1], cl

        sum_overflow:
        mov result[si], ch
        dec si
        cmp si, 0
        jl break_sum
        jmp loop_sum

    break_sum:
    ret
count_sum endp

count_diff proc
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]
    cmp al, bl

    je skipsum
        invert_sign num2
        call count_sum
        ret

    skipsum:
    call compare_nums
    cmp cmpres, 2
    jne not_swap
        call swap_nums
        invert_sign result

    not_swap:
    mov di, max_len
    mov al, num1[di]
    cmp al, 0
    je invert_sign_in_diff
        invert_sign result

    invert_sign_in_diff:
    mov si, max_len
    sub si, 1
    xor dh, dh 

    loop_diff:
        xor cx, cx
        mov ah, num1[si]
        mov bh, num2[si]
        add ch, ah
        sub ch, bh
        sub ch, dh
        xor cl, cl 
        xor dh, dh 
        if_less ch, cl, diff_overflow
            add ch, set_radix
            mov dh, 1

        diff_overflow:
        mov result[si], ch
        dec si
        cmp si, 0
        jl break_diff
        jmp loop_diff

    break_diff:
    ret
count_diff endp

count_prod proc
    mov di, max_len
    sub di, 1
    xor bx, bx

    loop_sumprod:
        mov si, max_len
        sub si, 1

        loop_prod:
            xor ax, ax
            xor cx, cx
            xor dx, dx
            mov al, num1[si]
            mov dl, num2[di]
            mul dx
            mov cl, set_radix
            div cl          
            sub si, bx
            add result[si - 1], al
            add result[si], ah
            add si, bx
            dec si
            cmp si, 0
            jl break_prod
            jmp loop_prod

        break_prod:
        inc bx
        dec di
        cmp di, 0
        jl break_sumprod
        jmp loop_sumprod

    break_sumprod:
    mov di, max_len
    sub di, 1

    loop_fix:
        xor ax, ax
        mov cl, set_radix
        mov al, result[di]
        div cl
        add result[di - 1], al
        mov result[di], ah
        dec di
        cmp di, 0
        jl break_fix
        jmp loop_fix

    break_fix:
    mov di, max_len
    push ax
    push bx
    mov al, num1[di]
    mov bl, num2[di]
    xor al, bl
    mov result[di], al
    pop bx
    pop ax
    ret
count_prod endp

start:
    mov ax, data
    mov ds, ax
    
    ; Ввод данных
    println prompt_radix
    scanchar set_radix
    cmp set_radix, '1'
    je handle_10
    cmp set_radix, '2'
    je handle_16
    print error_bad_symbol
    jmp endprogram

    handle_10:
        mov set_radix, 10
        jmp continue

    handle_16:
        mov set_radix, 16

    continue:
    println prompt_operation
    scanchar operation
    cmp operation, '+'
    je process_operation
    cmp operation, '-'
    je process_operation
    cmp operation, '*'
    je process_operation
    print error_bad_symbol
    jmp endprogram

    process_operation:
        println prompt_numbers
        scannum num1
        scannum num2
        xor dx, dx
        mov result[0], dh

        cmp operation, '+'
        je calculate_sum
        cmp operation, '-'
        je calculate_diff
        cmp operation, '*'
        je calculate_prod
        jmp endprogram

    calculate_sum:
        call count_sum
        jmp print_and_end

    calculate_diff:
        call count_diff
        jmp print_and_end

    calculate_prod:
        call count_prod

    print_and_end:
        mov dx, offset result
        push dx
        call numtostring
        println string

    endprogram:
        mov ah, 4Ch
        int 21h

code ends
end start