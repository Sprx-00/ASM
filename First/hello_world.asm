; 	*** Please refer to cheatsheet.txt for more info about registers and variable ***

section .data							; Define initialized variables
	message db "Hello World!", 10		; Define the output message. 10 = \n
	
	length equ $-message				; Length of the message. $ =  last offset
	
section .text							; Executable data
	global _start						; Make _start visible to the entire program
	
_start:									; Our main function
	mov rax, 1 							; RAX = 1 write
	mov rdi, 1 							; stdout
	mov rsi, message 					; Addr of text rsi
	mov rdx, length 					; rdx = no of bytes
	syscall								; Invoke the kernel
	
	; ** In assembly we need to manually exit once were done or else its a segfault.

	mov rax, 60 						; exit syscall
	xor rdi, rdi 						; exit status 0
	syscall								; Tell the kernel we want to exit
