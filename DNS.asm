%include "io.inc"

CEXTERN fopen
CEXTERN fclose
CEXTERN fscanf
CEXTERN fprintf
CEXTERN malloc
CEXTERN qsort
CEXTERN free
CEXTERN strcmp

section .rodata
    name1 db "input.txt", 0
    name2 db "output.txt", 0
    r db "r", 0
    w db "w", 0
    lc0 db "%d", 0
    lc1 db `%100s %u\n`, 0
    lc2 db "%100s", 0
    lc3 db `-1\n`, 0
    lc4 db `%u\n`, 0
    map_size dd 105

section .bss
    n resd 1
    m resd 1
    a resd 1
    s resb 101
    

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    and esp, -16
    sub esp, 16
    
    call fop_r
    mov esi, eax ;esi: FILE *src
    mov [esp], esi
    mov dword[esp + 4], lc0
    mov dword[esp + 8], n
    call fscanf
    
    mov eax, [n]
    mul dword[map_size]
    mov [esp], eax
    call malloc
    mov [a], eax
    
    mov ebx, [n]
    sub esp, 16
    mov [esp], esi
    mov dword[esp + 4], lc1
    xor edi, edi
.read:
    mov eax, [a]
    add eax, edi
    mov [esp + 8], eax
    add eax, 101
    mov [esp + 12], eax
    call fscanf
    mov eax, [esp + 8]
    add edi, [map_size]
    dec ebx
    jnz .read
    
    mov eax, [a]
    mov [esp], eax
    mov eax, [n]
    mov [esp + 4], eax
    mov eax, [map_size]
    mov [esp + 8], eax
    mov dword[esp + 12], strcmp  
    call qsort
    add esp, 16
    
    mov [esp], esi
    mov dword[esp + 4], lc0
    mov dword[esp + 8], m
    call fscanf
    
    call fop_w
    mov edi, eax
    
.mining:
    mov [esp], esi
    mov dword[esp + 4], lc2
    mov dword[esp + 8], s
    call fscanf
    
    mov eax, [n]
    mov [esp], eax
    mov eax, [a]
    mov [esp + 4], eax
    mov dword[esp + 8], s
    call bin_search

    cmp eax, -1
    je .not
    mov [esp], edi
    mov dword[esp + 4], lc4
    mov ebx, [a]
    mul dword[map_size]
    mov ebx, [ebx + eax + 101]
    mov [esp + 8], ebx
    call fprintf
    jmp .condition
    
.not:
    mov [esp], edi
    mov dword[esp + 4], lc3
    call fprintf

.condition:
    dec dword[m]
    jnz .mining
      
    mov [esp], esi
    call fclose
    mov [esp], edi
    call fclose
    
    mov esp, ebp
    xor eax, eax
    ret
    

bin_search:
    push ebp
    mov ebp, esp
    sub esp, 24
    
    mov dword[ebp - 4], 0 ;l = 0
    mov eax, [ebp + 8]
    dec eax
    mov [ebp - 8], eax ;r = n - 1
    
.bs_while: ;(l < r)
    mov eax, [ebp - 4]
    cmp eax, [ebp - 8]
    jge .bs_break
    add eax, [ebp - 8]
    shr eax, 1 ;mean
    mov [ebp - 12], eax
    mul dword[map_size]
    add eax, [ebp + 12] 
    mov [esp], eax ;a[m].name
    mov eax, [ebp + 16]
    mov [esp + 4], eax ;s
    call strcmp
    
    cmp eax, 0 ;(strcmp(a[m].name, s) < 0)
    jge .bs_else
    mov ecx, [ebp - 12]
    inc ecx
    mov [ebp - 4], ecx ;l = m + 1;
    jmp .bs_while

.bs_else:
    mov ecx, [ebp - 12]
    mov [ebp - 8], ecx ;r = m
    jmp .bs_while
    
.bs_break:    
    mov eax, [ebp - 8]
    mul dword[map_size]
    add eax, [ebp + 12]
    mov [esp], eax
    mov eax, [ebp + 16]
    mov [esp + 4], eax
    call strcmp ;(strcmp(a[r].name, s))
    test eax, eax
    
    jnz .bs_not
    mov eax, [ebp - 8] ;return r
    jmp .bs_end
.bs_not:
    mov eax, -1
    jmp .bs_end

.bs_end:
    mov esp, ebp
    pop ebp
    ret


fop_r:
    push ebp
    mov ebp, esp
    push dword r
    push dword name1
    call fopen
    mov esp, ebp
    pop ebp
    ret
      
fop_w:
    push ebp
    mov ebp, esp
    push dword w
    push dword name2
    call fopen
    mov esp, ebp
    pop ebp
    ret