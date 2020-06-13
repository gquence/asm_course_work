;*****************************************
;**** Автор: Аншуков Михаил Андреевич ****
;****                 Студент НИУ МАИ ****
;****                        2020 год ****
;*****************************************

MACRO switc!h src_char, end_label, [arg]
{
    match =(char==>label=), arg
    \{
        if src_char eq \char
            right_label = label
        end if
    \}
    common
    if (defined right_label)
        display "found",13,10
        jmp right_label
    else
        display "not found",13,10
        jmp end_label
    end if
}


; first functional part version
MACRO switc!h src_char, end_label, [arg]
{
    common
    if src_char in <al, ah, bl, bh, eax, ebx> | end_label in <al, ah, bl, bh, eax, ebx>
        display "warning: al, ah, bl, bh, eax, ebx are using in macro 'switc!h'"
    else
        common
        ; сохранение в стэк изначальных значений 
        push eax
        push ebx

        ; al  - регистр для исходного-целевого значения
        ; ebx - регистр-флаг для условного перехода по 
        ;       адресу в случае соответствия 
        mov al, src_char
        mov ebx, 0

        forward
        match =(char==>label=), arg
        \{
            ;сравнение исходного целевого значения с остальными введеными
            cmp al, \char
            ;загрузка активного адреса в регистр-флаг при соответствии
            jne @f
            lea ebx, [\label ]
@@: 
        \}
        common
        ; проверка регистра-флага (если сооответствия не было,\
        ; то переход на end_label, иначе переход на активный адрес)
        cmp ebx, 0
        je end_label
        jmp ebx

        ; вывод из стэка изначальных значений 
        pop ebx
        pop eax
    end if
}


; after report #1 13.06.20

MACRO switc!h src_char, end_label, [char, label]
{
    common
    if src_char in <al, ah, ax, eax> | end_label in <al, ah, ax, eax>
        display "warning: al, ah, ax, eax are using in macro 'switc!h'"
    else
    common
        ; сохранение в стэк изначальных значений 
        push eax
        
        ; al  - регистр для исходного-целевого значения
        ; ah  - регистр-флаг (обработка случая default(без совпадения))
        mov al, src_char
        mov ah, 0

    forward
        ; если метка пустая
        match  ,label
        \{
            display "empty label", 13, 10
            jmp @f
        \}
        match var, label
        \{
            display "not empty label", 13, 10
            ;сравнение исходного целевого значения с остальными введеными
            cmp al, char
            jne @f	;   переход, если не совпадают при соответствии

            ; операции при совпадении
            mov ah, 1
            pop eax
            jmp label
@@:
        \}
    common
        cmp ah, 1
        je @f
        ; случай без совпадении вообще
        pop eax
        jmp end_label
@@:
    end if
}