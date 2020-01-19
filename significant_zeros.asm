%include "io.inc"

section .data
    len dd 33

section .bss
    c resd 31 * 31
    n resd 1
    
section .text
global CMAIN
CMAIN:
    GET_UDEC 4, n
    inc dword[n]
    mov eax, dword[n]
.len_cnt:
    sal eax, 1
    dec dword[len]
    jnc .len_cnt
   
    ;creating Pascal's triangle:
    ;esi - row, edi - column
    mov esi, 0 ;for (esi = 0; esi < len; esi++)

.l1:
    mov ecx, esi
    imul ecx, dword[len]
    imul ecx, 4
    ;c[esi][0] = c[esi][esi] = 1;
    mov dword[c + ecx], 1
    mov dword[c + ecx + esi * 4], 1
    
    cmp esi, 1
    jle .external
    mov edi, 1 ;for (edi = 1; edi < esi; edi++)
.l2: 
    ;c[esi][edi] = c[esi-1][edi-1] + c[esi-1][edi];
    lea edx, [esi * 4 - 4]
    imul edx, dword[len]
    mov eax, dword[c + edx + edi * 4]
    add eax, dword[c + edx + edi * 4 - 4]
    mov dword[c + ecx + edi * 4], eax
    inc edi
    cmp edi, esi
    jl .l2
.external:    
    inc esi
    cmp esi, dword[len]
    jl .l1
    
    xor eax, eax 
    GET_UDEC 4, edi ;k
    cmp edi, dword[len]
    jge .end
    
    lea ebx, [esi * 4 - 4] ;ebx = len - 1
    imul ebx, esi
    mov eax, dword[c + ebx + edi * 4 + 4]
    
    lea ecx, [esi - 2] ;current shift
.while: ;(ecx >= 0 && edi > 0)
    cmp ecx, -1
    je .end
    test edi, edi
    jz .end
    ;if ((a >> ecx) & 1))
    mov ebx, dword[n];
    shr ebx, cl
    test ebx, 1 
    jz .else
    ;eax += c[ecx][edi-1]
    mov edx, dword[len]
    imul edx, ecx
    imul edx, 4
    add eax, dword[c + edx + 4 * edi - 4]
    jmp .continue
.else:
    dec edi
.continue:
    dec ecx
    jmp .while
    
.end: 
    PRINT_UDEC 4, eax
    xor eax, eax
    ret%include "io.inc"

section .data
    len dd 33

section .bss
    c resd 31 * 31
    n resd 1
    
section .text
global CMAIN
CMAIN:
    GET_UDEC 4, n
    inc dword[n]
    mov eax, dword[n]
.len_cnt:
    sal eax, 1
    dec dword[len]
    jnc .len_cnt
   
    ;creating Pascal's triangle:
    ;esi - row, edi - column
    mov esi, 0 ;for (esi = 0; esi < len; esi++)

.l1:
    mov ecx, esi
    imul ecx, dword[len]
    imul ecx, 4
    ;c[esi][0] = c[esi][esi] = 1;
    mov dword[c + ecx], 1
    mov dword[c + ecx + esi * 4], 1
    
    cmp esi, 1
    jle .external
    mov edi, 1 ;for (edi = 1; edi < esi; edi++)
.l2: 
    ;c[esi][edi] = c[esi-1][edi-1] + c[esi-1][edi];
    lea edx, [esi * 4 - 4]
    imul edx, dword[len]
    mov eax, dword[c + edx + edi * 4]
    add eax, dword[c + edx + edi * 4 - 4]
    mov dword[c + ecx + edi * 4], eax
    inc edi
    cmp edi, esi
    jl .l2
.external:    
    inc esi
    cmp esi, dword[len]
    jl .l1
    
    xor eax, eax 
    GET_UDEC 4, edi ;k
    cmp edi, dword[len]
    jge .end
    
    lea ebx, [esi * 4 - 4] ;ebx = len - 1
    imul ebx, esi
    mov eax, dword[c + ebx + edi * 4 + 4]
    
    lea ecx, [esi - 2] ;current shift
.while: ;(ecx >= 0 && edi > 0)
    cmp ecx, -1
    je .end
    test edi, edi
    jz .end
    ;if ((a >> ecx) & 1))
    mov ebx, dword[n];
    shr ebx, cl
    test ebx, 1 
    jz .else
    ;eax += c[ecx][edi-1]
    mov edx, dword[len]
    imul edx, ecx
    imul edx, 4
    add eax, dword[c + edx + 4 * edi - 4]
    jmp .continue
.else:
    dec edi
.continue:
    dec ecx
    jmp .while
    
.end: 
    PRINT_UDEC 4, eax
    xor eax, eax
    ret