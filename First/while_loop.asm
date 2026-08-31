; Example of while loop
; Ask the user to input the letter "string"
; Compare user input with our 'string' variables
; Break if comparision is successful

;   *** Please refer cheatsheet.txt for more info on registers and other variables ***

section .rodata        ; Read only data
    final db "Congrats", 10
    len_final equ $ - final

    message db "Please enter the word 'string'", 10
    msg_len equ $ - message

    string db "string", 10 ; Our string

    prompt db "$ ", 0
    len_prompt equ $ - prompt

    invalid db "String doesnt match", 10
    len_invalid equ $ - invalid

    short_string db "Too short", 10
    len_short_string equ $ - short_string

section .bss        ; We can reserve memory here
    user resb 20    ; Reserve 20 bytes for user input

section .data
    counter dq 0    ; Our counter

section .text
    global _start

_start:
    ; Check if counter is equal to 1
    cmp qword [rel counter], 1
    jne display_message ; Jump to display_message if not

    ; Display prompt to stdout
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, len_prompt
    syscall

    ; Read from stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, user
    mov rdx, 20
    syscall

    cmp rax, 5 ; rax = number of bytes Read. Compare it with 5
    jl too_short ; Jump to too_short if read() returned less then 4 bytes

    cmp rax, 7  ; Compare if user input 7 bytes (including \n)
    jne invalid_string  ; Jump to invalid_string if the len of user input isnt 7 bytes

    jmp compare_string  ; Jump to compare_string

too_short:
    ; Display the "Too short" message
    mov rax, 1
    mov rdi, 2  ; stderr
    mov rsi, short_string
    mov rdx, len_short_string
    syscall

    jmp _start ; Jump back to start

invalid_string:
    ; Display err message to stderr
    mov rax, 1
    mov rdi, 2
    mov rsi, invalid
    mov rdx, len_invalid
    syscall

    jmp _start ; Jump back to _start

compare_string:
    ; Compare each byte the user enterd with the chars of 'string\n'
    ; NOTE: The count starts from 0
    ; Were using relative address (rel)

    ; Move the first character of user input into al
    ; And compare al with the first byte of string
    mov al, [rel user]
    cmp al, [rel string]
    ; Jump to invalid_string if not equal
    jne invalid_string

    ; Move the next byte and compare
    mov al, [rel user+1]
    cmp al, [rel string+1]
    jne invalid_string

    mov al, [rel user+2]
    cmp al, [rel string+2]
    jne invalid_string

    mov al, [rel user+3]
    cmp al, [rel string+3]
    jne invalid_string

    mov al, [rel user+4]
    cmp al, [rel string+4]
    jne invalid_string

    mov al, [rel user+5]
    cmp al, [rel string+5]
    jne invalid_string

    mov al, [rel user+6]
    cmp al, [rel string+6]
    jne invalid_string

    ; Not comparing the \n

    ; Jump to success if all bytes matched
    jmp success

display_message:
    ; Display the message
    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, msg_len
    syscall

    ; Increment counter
    inc qword [rel counter] ; Since counter is 1 now this function will never be called again

    jmp _start ; Go back to _start

success:
    mov rax, 1
    mov rdi, 1
    mov rsi, final
    mov rdx, len_final
    syscall

    ; Exit with code 0
    mov rax, 60
    mov rdi, 0
    syscall