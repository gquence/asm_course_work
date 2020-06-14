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
        match ,end_label
        \{
            display "end_label is not exist",13,10
            jmp @f
        \}
        jmp end_label
    @@:
    end if
}

MACRO JUMP all_args
{
    common
    match =?:==src_char =(other_args, all_args
    \{
        ; char_args      - исходная строка аргументов
        ; args_strings   - результирующая(необходимая) строка для макроса switc!h
        ; last_elem_flag - флаг для бесконечного цикла
        ;
        ; match1_flag \           флаги проверки match 
        ; match2_flag -->  для исключения входа в макрос switc!h 
        ; match3_flag /       с неверными значениями аргументов

        char_args equ (\other_args
        args_string equ \src_char
        last_elem_flag equ 0
        \match1_flag equ 1
        \match2_flag equ 1
        \match3_flag equ 1

        while \\match3_flag eq 1
            ; добавление end_label как второго параметра макроса switc!h
            match something=)==>label, char_args
            \\{
                args_string equ  args_string, \label
                char_args equ \something)
                \\match1_flag equ 0
            \\}
            ; два костыля для проверки исключительных ситуаций,\
            ; чтобы избежать бесконечного цикла
            match something=)=>label, char_args
            \\{
                \\match1_flag equ 1
                break
            \\}
            match something=)==label, char_args
            \\{
                \\match1_flag equ 1
                break
            \\}

            ; добавление char и label как 3-го и старше параметров макроса switc!h
            common match =(char==>label=) other_char_args, char_args
            \\{
                args_string equ args_string, \char,  \label
                char_args equ \other_char_args
                \\match2_flag equ 0
            \\}
            ; добавление char и label как ПОСЛЕДНИХ параметров макроса switc!h\
            ; и выход из цикла
            common match =(char==>label=), char_args
            \\{
                args_string equ args_string, \char,  \label
                \\match3_flag equ 0
                break
            \\}
            ; проверка, которая не работает :( (непонятно почему)
            if (\match1_flag eq 1) & (\match2_flag eq 1) & (\match3_flag eq 1)
                display "Invalid arguments",13,10
            end if
            \match2_flag equ 1
        end while 
        ; проверка, на валидность аргументов\
        ; (должен быть минимум одна пара 'char' 'label' и 'end_label')
        if (\match1_flag eq 1) | (\match3_flag eq 1)
            display "Invalid arguments",13,10
        else
            common
            match params, args_string
            \\{
                switc!h  \params
            \\}
        end if 
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
    JUMP ?:=dh (':' => hello) ('a' => no_you) => endlabel
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