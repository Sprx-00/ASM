; ** Reads only 3 bytes in age. So if you enter 99 it is "9", "9", "\n" so were all good
;    but if you enter 100 it is "1", "0", "0", "\n" which is 4 bytes so it will only print
;    the first 2 bytes ("1", "0") as the program considers the third char to be \n

;   *** Please refer cheatsheet.txt for more info on registers and other variables ***

; Compile with: nasm -f elf64 ask_user.asm -o ask_user.o && ld ask_user.o -o ask_user
; And finally run it with ./ask_user

section .rodata                                     ; Read only data section
    NAME db "Sprx~", 10                             ; 10 means a newline '\n'. db - Define 1 byte
    lenNAME equ $ - NAME                            ; We can store already defined variables here

    greet1 db "Hey there, ", 0                      ; The first message. 0 simply means '\0'. It isnt necessary to add 0 but im doing it anyway. And were not adding 10 at the ending because the age has to be printed at the same line
    lgreet1 equ $ - greet1                          ; The length of the greet1 message. $ is the location of the previous =====================================

    greet2 db ". You are ", 0                       ; Same here second message. im adding whitespaces because theres no space formatting here
    lgreet2 equ $ - greet2                          ; Length of greet2

    greet3 db " years old", 10                      ; Same here
    lgreet3 equ $ - greet3                          ; Length

    prompt db "Please enter you name and age", 10   ; The prompt that will be displayed when the program will run. You can write anything but i chose this simple text
    lprompt equ $ - prompt                          ; Length of the prompt

    display1 db "Name: ", 0                         ; The input message -> "Name: "
    ldisplay1 equ $ - display1                      ; Length of this message

    display2 db "Age: ", 0                          ; Age input message "Age: "
    ldisplay2 equ $ - display2                      ; Length

    errmsg db "Error: Age can only be int", 0       ; Error message in case the user inputs a non int value
    errlen equ $ - errmsg                           ; Length of the error message

                                                    ; For example im storing my name and length of my name

section .bss                                        ; Reserved memory area
    age resb 10                                     ; Take a variable "age" and reserve 10 bytes. resb - reserve 1 byte each
    name resb 30                                    ; Name reserved 30 bytes

section .text                                       ; We can execute code in this section
    global _start                                   ; Make the _start section global so that the it is visible to the linker

print_dev:                                          ; My function to print NAME at .rodata
    mov rax, 1                                      ; mov - move, rax - accumilator / syscall number, 1 - write. Move 1 to rax to tell the kernel we want to write to screen
    mov rdi, 1                                      ; rdi - first argument / destination. 1 - stdout. Write to stdout
    mov rsi, NAME                                   ; rsi - second argument / source. Move NAME (Sprx~) to rsi 
    mov rdx, lenNAME                                ; rdx - third argument / data. How many bytes to write
    syscall                                         ; Invoke the kernel
    
    ret                                             ; ret - return. Return to the function who called it

take_inputs:                                        ; Function to take input: name and age
    mov rax, 1                                      ; Over here rax changes into the number of bytes written so we need to set it to 1 each time we want to perform write
    mov rdi, 1                                      ; Write to stdout
    mov rsi, display1                               ; Point to display1
    mov rdx, ldisplay1                              ; Point to length of display1 (ldisplay1)
    syscall                                         ; Invoke the kernel

    mov rax, 0                                      ; 0 - read. Swap to read (input) mode
    mov rdi, 0                                      ; Read from stdin (0)
    mov rsi, name                                   ; Put the entered string into name 
    mov rdx, 30                                     ; Read only 30 bytes from name
    syscall                                         ; Invoke the kernel to take input

    mov r10, rax                                    ; Move the number of bytes read (rax) into r10 (General purpose register) for later use
    dec r10                                         ; Reduce r10 by 1 to remove the \n

    mov rax, 1                                      ; Now switch to write mode
    mov rdi, 1                                      ; Write to stdout
    mov rsi, display2                               ; The display message "Age: "
    mov rdx, ldisplay2                              ; Length of this display message
    syscall                                         ; Invoke the kernel

    mov rax, 0                                      ; rax:0 = read()
    mov rdi, 0                                      ; rdi:0 = stdin
    mov rsi, age                                    ; Point rsi to store value at age
    mov rdx, 3                                      ; adi:3 accept only 3 bytes. 2 bytes for the age and last 1 byte for '\n'
    syscall                                         ; Perform the read()

    mov r12, rax                                    ; Move the number of bytes read (rsi) into r112 (General purpose register the syscall doesnt cobble up) for later use

    jmp check_int

check_int:                                          ; Function to check if the age input is an integer
    mov rsi, age                                    ; rsi is the address of age
    mov al, [rsi]                                   ; Now al = first character entered

    cmp al, 10                                      ; Compare if al is \n. If yes then exit as the user didnt input any age
    je not_number                                   ; je = jump if equal

    cmp al, '0'                                     ; Compare al with '0' which is 48 in ASCII
    
    ; In ASCII number range from 48-57. ["0" = 48, "1" = 49, ...... , "9"=57]

    jl not_number                                   ; jl = jump if less. A valid number has to be larger then 48 in ASCII

    cmp al, '9'                                     ; compare if al is greater then '9' which is 57 in ASCII
    jg not_number                                   ; jg = jump if greater. A valid int cant be larger then 57 in ASCII

    inc rsi                                         ; inc = increment. Move to the next number in rsi
    mov al, [rsi]                                   ; Copy the next digit into al

    cmp al, 10                                      ; Compare if the next digit is actually the end. For single digit age input
    je prints_success                               ; Jump to prints_success immidiately if yes

    cmp al, '0'                                     ; Same happening here but with the next value of al
    jl not_number                                   ; Same thing

    cmp al, '9'                                     ; Same thing
    jg not_number                                   ; Same thing

    jmp prints_success                              ; jmp = jump unconditionally. Jump to our function to print "Hey there, $name. You are $age years old.\b" if everything before went smoothly

not_number:                                         ; Function to handle non int age error
    mov rax, 1                                      ; Perform write()
    mov rdi, 2                                      ; Switch to stderr (2)
    mov rsi, errmsg                                 ; The error message   
    mov rdx, errlen                                 ; How many bytes to print
    syscall

    mov rax, 60                                     ; 60 = exit()
    mov rdi, 1                                      ; Our exitcode which we will set to 1
    syscall                                         ; Tell the kernel we want to exit with code 1

prints_success:
    mov rax, 1                                      ; write()
    mov rdi, 1                                      ; stdout
    mov rsi, greet1                                 ; "Hey there, "
    mov rdx, lgreet1                                ; Length
    syscall                                         ; Invoke kernel

    mov rax, 1                                      ; write()
    mov rdi, 1                                      ; stdout
    mov rsi, name                                   ; User entered name
    mov rdx, r10                                    ; Length of users name
    syscall                                         ; Invoke kernel

    ; Write other part of greeting (greet2, greet3)

    mov rax, 1
    mov rdi, 1
    mov rsi, greet2
    mov rdx, lgreet2
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, age          
    
    dec r12                                         ; Remove the \n
                              ; 
    mov rdx, r12
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, greet3
    mov rdx, lgreet3
    syscall

    ; Now exit with code 0 to indicate successful exit

    mov rax, 60
    mov rdi, 0
    syscall

_start:
    mov rax, 1                                      ; Move 1 into rax to indicate write
    mov rdi, 1                                      ; Point to stdout
    mov rsi, prompt                                 ; Move the source message which is prompt into rsi
    mov rdx, lprompt                                ; How many bytes to print
    syscall                                         ; Invoke the kernel

    jmp take_inputs                                 ; Jump to take_inputs

    ; Shouldnt reach here
    mov rax, 60
    mov rdi, 0
    syscall