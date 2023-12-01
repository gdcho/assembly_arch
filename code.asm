section .bss
    input resb 256         ; Reserve a buffer of 256 bytes for the input

section .data
    msg db 'Output: ', 0

section .text
global _start

_start:
    ; Print prompt message
    mov eax, 4            ; syscall number for sys_write
    mov ebx, 1            ; file descriptor 1 is stdout
    mov ecx, msg          ; pointer to message
    mov edx, 9            ; Corrected message length
    int 0x80              ; call kernel

    ; Read string from user
    mov eax, 3            ; syscall number for sys_read
    mov ebx, 0            ; file descriptor 0 is stdin
    mov ecx, input        ; pointer to input buffer
    mov edx, 255          ; number of bytes to read
    int 0x80              ; call kernel
    dec eax               ; Decrement eax to exclude the newline character
    mov byte [ecx+eax], 0 ; replace newline with null terminator
    mov esi, eax          ; save the string length (excluding null terminator)

    ; Convert string to uppercase
convert_loop:
    mov al, [ecx]         ; load next byte of input
    test al, al           ; check for null terminator
    jz reverse_string    ; if zero, proceed to reverse string
    cmp al, 'a'           ; check if character is lowercase
    jb next_char
    cmp al, 'z'
    ja next_char
    sub al, 32            ; convert to uppercase
    mov [ecx], al         ; store back in buffer
next_char:
    inc ecx               ; move to next character
    jmp convert_loop

    ; Reverse the string
reverse_string:
    dec ecx               ; Adjust ecx to point to the last character of the string
    lea ebx, [input]      ; Load the address of the input buffer into ebx
reverse_loop:
    cmp ebx, ecx          ; Compare pointers
    jge print             ; If ebx is greater or equal to ecx, the string is reversed
    mov al, [ebx]         ; Swap the characters
    mov ah, [ecx]
    mov [ebx], ah
    mov [ecx], al
    inc ebx               ; Move ebx to the next character
    dec ecx               ; Move ecx to the previous character
    jmp reverse_loop

    ; Print the uppercase and reversed string
print:
    mov eax, 4            ; syscall number for sys_write
    mov ebx, 1            ; file descriptor 1 is stdout
    mov ecx, input        ; pointer to input buffer
    mov edx, esi          ; Corrected length of the string
    int 0x80              ; call kernel

    ; Exit program
    mov eax, 1            ; syscall number for sys_exit
    xor ebx, ebx          ; exit code 0
    int 0x80              ; call kernel
