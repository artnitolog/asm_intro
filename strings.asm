%include "io.inc"

CEXTERN strcmp
CEXTERN strcpy

section .rodata
    LC0 db `%d`, 0
    LC1 db `%10s`, 0
    len dd 11
    
section .bss
    s resb 5500 ;char s[500][10 + 1]
    cur resb 11 ;char cur[10 + 1]
    n resd 1

section .data
    m dd 0

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    and esp, -16
    sub esp, 16
    
    mov dword[esp + 4], n
    mov dword[esp], LC0
    call scanf
    
    mov dword[esp + 4], cur
.ext_loop:
    mov dword[esp], LC1
    call scanf
    
    xor esi, esi
.int_loop:
    cmp esi, [m]
    je .new
    lea edi, [s + esi]
    mov dword[esp], edi
    call strcmp
    test eax, eax
    je .already
    add esi, 11
    jmp .int_loop

.new:
    mov edi, s
    add edi, [m]
    mov [esp], edi
    call strcpy
    add dword[m], 11
    
.already:
    dec dword[n]
    jnz .ext_loop
    
    mov eax, dword[m]
    xor edx, edx
    div dword[len]
    mov [esp + 4], eax
    mov dword[esp], LC0
    call printf
    
    mov esp, ebp
    xor eax, eax
    ret