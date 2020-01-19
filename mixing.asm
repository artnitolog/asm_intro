%include "io.inc"

CEXTERN fopen
CEXTERN fclose
CEXTERN fscanf
CEXTERN fprintf
CEXTERN malloc
CEXTERN free

section .rodata
    name1 db "input.txt", 0
    name2 db "output.txt", 0
    r db "r", 0
    w db "w", 0
    lc0 db "%u ", 0
    node_size dd 12
    case1 db "1", 0
    
section .bss
    src resd 1
    dst resd 1
    n resd 1
    m resd 1
    a resd 1
    first resd 1
    second resd 1    

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    and esp, -16
    sub esp, 16
    call fop_r
    mov [src], eax
    call fop_w
    mov [dst], eax
    
    mov eax, [src]
    mov [esp], eax
    mov dword[esp + 4], lc0
    mov dword[esp + 8], n
    call fscanf
    mov dword[esp + 8], m
    call fscanf
    
    cmp dword[n], 1
    jne .ordinary_case
    ;if n == 1:
    call fclose
    mov eax, [dst]
    mov [esp], eax
    mov dword[esp + 4], case1
    call fprintf
    call fclose
    jmp .end
    
.ordinary_case:
    mov eax, [n]
    imul eax, dword[node_size]
    mov [esp], eax
    call malloc
    mov [a], eax

    mov [esp + 4], eax
    mov eax, [n]
    mov [esp], eax
    call list_init ;list_init(n, a);
    
    mov edi, [a]
    add edi, 4
    mov eax, [src]
    mov [esp], eax
    mov dword[esp + 4], lc0
.process:    
    dec dword[m]
    js .exit
    mov dword[esp + 8], first
    call fscanf
    mov dword[esp + 8], second
    call fscanf
    mov eax, dword[first]
    mov ebx, dword[second]
    imul eax, dword[node_size]
    imul ebx, dword[node_size]
    sub eax, 8
    sub ebx, 8
    add eax, [a] ;eax -> {first}
    add ebx, [a] ;ebx -> {second}
    cmp edi, eax
    je .process
    mov ecx, [eax - 4] ;ecx = {first}->prev
    mov edx, [ebx + 4] ;edx = {second}->next
    mov [ecx + 4], edx ;a[b]->prev->next = a[c]->next;
    test edx, edx
    jz .list_end
    mov [edx - 4], ecx ;a[c]->next->prev = a[b]->prev;
.list_end:
    mov [edi - 4], ebx
    mov [ebx + 4], edi
    mov dword[eax - 4], 0
    mov edi, eax
    jmp .process

.exit:   
    call fclose
    
    mov eax, [dst]
    mov [esp], eax
    mov dword[esp + 4], lc0
.print:
    mov eax, [edi]
    mov [esp + 8], eax
    call fprintf
    mov edi, [edi + 4]
    test edi, edi
    jnz .print
    
    call fclose
    mov eax, [a]
    mov [esp], eax
    call free
    
.end:
    mov esp, ebp
    xor eax, eax
    ret
    

list_init:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp + 12]
    add edi, 4
    mov ecx, 1
.numbers:
    mov [edi], ecx
    inc ecx
    add edi, dword[node_size]
    cmp ecx, [ebp + 8]
    jbe .numbers

    mov edi, [ebp + 12]
    add edi, 4
    mov dword[edi - 4], 0 ;a[0]->prev = NULL
    mov [edi + 8], edi ;a[1]->prev = a[0]
    cmp dword[ebp + 8], 2
    je .trivial
    
    mov ecx, [ebp + 8]
    sub ecx, 2
.links:
    add edi, dword[node_size]
    mov [edi - 8], edi
    mov [edi + 8], edi
    loop .links

.trivial:    
    add edi, dword[node_size]
    mov [edi - 8], edi ;a[n - 2]->next = a[n - 1]
    mov dword[edi + 4], 0 ;a[n - 1]->next = NULL
    
    pop edi
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