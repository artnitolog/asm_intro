;stdcall
%include "io.inc"

section .data
    mod dd 2011
    
section .bss
    n resd 1

section .text
global CMAIN
CMAIN:
    sub esp, 4
    GET_UDEC 4, [esp] ;k
    GET_UDEC 4, n
    GET_UDEC 4, eax
    xor edx, edx
    div dword[mod] ;edx = x0
    push edx
    push edx
    
.loop:
    call hash
    push edx
    push eax
    dec dword[n]
    jnz .loop
    
    PRINT_UDEC 4, eax
    add esp, 12
    xor eax, eax
    ret
    
    
hash: ;newer is closer to the top
    push ebp
    mov ebp, esp
    mov eax, dword[ebp + 12]
    xor ecx, ecx
    
.len_loop:
    inc ecx
    xor edx, edx
    div dword[ebp + 16] ; /k
    test eax, eax
    jnz .len_loop
    ;now ecx = len(x[i-1])

    mov eax, dword[ebp + 8]
.pow_loop: 
    mul dword[ebp + 16]
    div dword[mod]
    mov eax, edx
    loop .pow_loop
    ;now eax is the left part of answer
    
    add eax, dword[ebp + 12]
    xor edx, edx
    div dword[mod]
    mov eax, edx
    mov edx, dword[ebp + 8]
    
    mov esp, ebp
    pop ebp
    ret 8