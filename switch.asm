;*****************************************
;**** Автор: Аншуков Михаил Андреевич ****
;****                 Студент НИУ МАИ ****
;****                        2020 год ****
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
            display "not empty label", 13, 10
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
        cmp ah, 1
        je @f
        ; случай без совпадении вообще
        pop eax
        jmp end_label
    @@:
    end if
}

MACRO JUMP char_arg, [input_params]
{
    common
    match =?:==src_char, char_arg
    \{
        chars_and_labels equ 
        start_CAL = 1
        
        end_label equ 
        end_label_flag equ 0
        
        
        display "saucksess", 13,10
        forward
        match =(char==>label=), input_params
        \\{
            chars_and_labels equ chars_and_labels, \char,  \label
        \\}
        match ==>label, input_params
        \\{
            if end_label_flag eq 0
                end_label_flag equ 1
                end_label equ  label
            else
                display "wrong amount of ending(default) labels",13,10
            end if
        \\}
        common
        ; проверка аргументов на пустоту
        if end_label eq
            display "endind(default) label is not exist or wrong formated",13,10
        else if chars_and_labels eq
            display "comparing chars or labels are not exist or wrong formated",13,10
        else
            ;display \src_char, end_label chars_and_labels
        end if
    \}
    common
        switc!h \src_char, end_label chars_and_labels

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
    mov dh, ':'
    JUMP ?:=dh, ( ':'  => hello ), ('a' => no_you), =>endlabel
    ;switc!h dh, endlabel, 'a', hello,'b', 

; тестовый флаг при ошибке
    mov edx, wrong_wrd
    cinvoke printf, format_cstring, edx
    invoke exitprocess,0


;тестовые флаги
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