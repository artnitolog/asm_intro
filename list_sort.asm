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
    lc0 db "%d ", 0

section .bss
    x resd 1
    
section .data
    p dd 0

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    and esp, -16
    sub esp, 16
    call fop_r
    
    mov [esp], eax
    mov dword[esp + 4], lc0
    mov dword[esp + 8], x

.building:
    call fscanf
    cmp eax, 1
    jne .built
    sub esp, 16
    mov eax, [p]
    mov dword[esp], eax
    mov eax, [x]
    mov dword[esp + 4], eax
    call smart_push
    add esp, 16
    mov [p], eax
    jmp .building  
.built:
    call fclose

    call fop_w
    mov [esp], eax
    mov eax, [p]
    mov [esp + 4], eax
    call list_print_free
    call fclose
    
    mov esp, ebp
    xor eax, eax
    ret
    
    
smart_push:
    push ebp
    mov ebp, esp
    push ebx
    
    sub esp, 20
    mov dword[esp], 8 ;sizeof(list)
    call malloc
    mov [ebp - 8], eax ;list *q = malloc(sizeof(list))
    mov edx, [ebp + 12]
    mov [eax], edx ;q->data = x;
    
    mov ebx, [ebp + 8]
    test ebx, ebx ;if the passed list is empty
    jnz .elif
    mov dword[eax + 4], 0 ;q->next = NULL;
    jmp .push_end
    
.elif:
    cmp [ebx], edx ;if (p->data >= x)
    jl .while
    mov [eax + 4], ebx ;q->next = p;
    jmp .push_end

.while: ;(p->next && p->next->data < x)
    mov ecx, [ebx + 4]
    test ecx, ecx
    jz .break
    cmp [ecx], edx
    jge .break
    mov ebx, [ebx + 4]
    jmp .while
.break:    
    mov [ebx + 4], eax
    mov [eax + 4], ecx
    mov eax, [ebp + 8]

.push_end:
    add esp, 20
    pop ebx
    mov esp, ebp
    pop ebp
    ret


list_print_free:
    push ebp
    mov ebp, esp
    push ebx
    sub esp, 20

    mov ebx, [ebp + 12]

.pr_fr_while: ;the end of p isn't reached
    test ebx, ebx
    jz .pr_fr_break
    mov eax, [ebp + 8]
    mov [esp], eax
    mov dword[esp + 4], lc0
    mov eax, [ebx]
    mov dword[esp + 8], eax
    call fprintf
    mov [esp], ebx
    mov ebx, [ebx + 4]
    call free
    jmp .pr_fr_while

.pr_fr_break:
    add esp, 20
    pop ebx    
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
