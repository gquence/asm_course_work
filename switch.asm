;*****************************************
;**** Автор: Аншуков Михаил Андреевич ****
;****                 Студент НИУ МАИ ****
;****                  20.06.2020 год ****
;*****************************************
;Задание	Реализовать оператор
;		Если_это_Символ_то_Перейти_в \
;			?:=al \
;	      ( ':'  => instruction_separator )\ ......
;*********************************************************

;S!WITCL al,FEND,”:”, instruction_separator,………
;********************************************************


FORMAT PE console
entry start

include 'C:\FASM\\include\win32a.inc'


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
            ;сравнение исходного целевого значения с остальными введеными
            cmp al, char
            jne @f	;   переход, если не совпадают при соответствии

            ; операции при совпадении
            mov ah, 1
            pop eax
            jmp label
        \}
    @@:

    common
        xor ah, 1
        jz @f
        ; случай без совпадении вообще
        pop eax
        match ,end_label
        \{
            display "end_label is not exist",13,10
            jmp @f
        \}
        jmp end_label
    @@:
    end if
}

MACRO Если_это_Символ_то_Перейти_в  all_args
{
    args_string equ

    ;получение первого аргумента (исходное сравниваемое значение)
    common
    match =?:==char =(others, all_args
    \{
        args_string equ \char
        ; получение end_label
        match something=)==>label, all_args
        \\{
            args_string equ args_string, \label
        \\}
        ;получение аргументов вида char => label
        tmp_args equ
        irps arg, (\others
        \\{
            ; аккумуляция строки по-символьно
            tmp_args equ tmp_args \\arg

            ; добавление char и label как 3-го и старше параметров макроса switc!h
            match =(char==>label=), tmp_args
            \\\{
                args_string equ args_string, \char,  \label
                tmp_args equ 
            \\\}
        \\}
    \}

    match params, args_string
    \{
        switc!h \params
    \}
}



;Начало программы
section '.data' data writeable readable

no_you_wrd: db "no_you",0
hello_wrd db "hello",0
end_wrd db "end",0
wrong_wrd db "test not passed",0

format_cstring db "%s",0
format_int db '%d',0

section '.code' code readable executable
start:
    mov dh, 's'
    ; 
    Если_это_Символ_то_Перейти_в ?:=dh ('a'=>hello) ('b'=>no_you) ('g'=>l1)  => endlabel
    ;switc!h dh, endlabel, 'a', hello,'b', 

; тестовый флаг при ошибке
    mov edx, wrong_wrd
    cinvoke printf, format_cstring, edx
    invoke exitprocess,0


;тестовые флаги
l1:
    cinvoke printf, format_int, 1
    invoke exitprocess,0
no_you:
    mov edx, no_you_wrd
    cinvoke printf, format_cstring, edx
    invoke exitprocess,0
hello:
    mov edx, hello_wrd
    cinvoke printf, format_cstring, edx
    invoke exitprocess,0

endlabel:
    mov edx, end_wrd
    cinvoke printf, format_cstring, edx
    invoke exitprocess,0

section '.idata' import readable writeable
library kernel32, 'kernel32.dll',\
        crtdll, 'crtdll.dll'

import kernel32,\
    exitprocess, 'ExitProcess' 

import crtdll,\
    printf, 'printf'