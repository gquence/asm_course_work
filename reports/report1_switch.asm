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
            jne @f		;   а почему не сразу je \label  
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
    mov dh, 'a'
    switc!h dh, endlabel, ('a'=>hello),('b'=>no_you)

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