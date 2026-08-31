secton .bss
    no1 resb 20 ; Reserve 20 bytes for user input
    no2 resb 20

section .rodata:
    message db "Please enter 2 numbers", 10
    len1 equ $ - message

    prompt1 db "First number: ", 0
    len2 equ $ - prompt1
    prompt2 db "Second number: ", 0
    len3 equ $ - prompt2

    errmsg db "Invalid number", 10
    len err_msg equ $ - errmsg

    err_opt db "You can only choose 1, 2, 3, 4 or 5", 10
    opt_len equ $ - err_opt

section .data
    counter dq 0    ; add / sub / div / miltiply?
    number1 dq 0    ; First number
    number2 dq 1    ; Second number

section .text
    global _start
