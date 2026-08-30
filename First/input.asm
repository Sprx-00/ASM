; *** Please refer cheatsheet.txt for more info on registers and other variables ***
; Compile with: nasm -f elf64 input.asm -o input.o && ld input.o -o input
; Finally run with: ./input

section .rodata     ; Read only data section. For variable you want to predefine
    message db "Enter: ", 0     ; Our prompt for this example
    len equ $ - message         ; $ = last offset.

    final db "You entered: ", 0 ; Our message to print after the user input 
    len_final equ $ - final     ; Length of our final message

section .bss        ; Reserved memory area
    input resb 30   ; Reserve 30 bytes in memory for variable 'input'

section .text       ; Executable section
    global _start   ; Make the _start section global

_start:              ; Our main function
    mov rax, 1       ; write mode
    mov rdi, 1       ; stdout
    mov rsi, message ; Take message as the argument
    mov rdx, len     ; Length of message. how many bytes to write
                     ; So 29 (user input) + 1 (\n) = 30
    syscall          ; Tell the linux kernel to perform write

    mov rax, 0       ; Switch to read mode
    mov rdi, 0       ; Read from stdin
    mov rsi, input   ; Store the input in var 'input'
    mov rdx, 29      ; Read 29 bytes as last byte has to be \n
    syscall          ; Tell the kernel to perform read

    mov r12, rax     ; Copy the rax (how many bytes the user inputted) into r12 register (General purpose register)
                     ; Were copying rax to r12 because rax will be overwritten after each syscall

    mov rax, 1       ; write
    mov rdi, 1       ; stdout
    mov rsi, final   ; Display the final message
    mov rdx, len_final ; Length
    syscall

    mov rax, 1       ; write
    mov rdi, 1       ; stdout
    mov rsi, input   ; Take input as the argument
    mov rdx, r12     ; r12 as before how many bytes long is the input
    syscall

    mov rax, 60      ; 60 = exit syscall
    mov rdi, 0       ; 0 = our returncode to indicate successful run
    syscall          ; exit the program

