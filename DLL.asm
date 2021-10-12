segment .data
    printformat     db  "%d", 10,  0

segment .bss
    dllPointer      resd 1    

segment .text
    extern    printf
    extern    malloc
    global    main

main: 
    enter   0, 0
    pusha


    call    makelist
    mov     DWORD[dllPointer], eax

    push    10 
    push    DWORD[dllPointer]
    call    insertSorted
    add     esp, 8

    push    15
    push    DWORD[dllPointer]
    call    insertSorted
    add     esp, 8

    push    12
    push    DWORD[dllPointer]
    call    insertSorted
    add     esp, 8

    push    DWORD[dllPointer]
    call    printerF
    add     esp, 4

    popa
    mov     eax, 0
    leave
    ret

makelist: ; struct dllheader *makelist()
    push    ebp
    mov     ebp, esp
    
    push    12
    call    malloc
    add     esp, 4
    mov     DWORD[eax], 0
    mov     DWORD[eax+4], 0
    mov     DWORD[eax+8], 0 

    mov     esp, ebp
    pop     ebp
    ret

makenode: ; struct lnode *makenode(int num)
    push    ebp
    mov     ebp, esp

    push    12
    call    malloc
    add     esp, 4
    mov     DWORD[eax], 0
    mov     DWORD[eax+4], 0
    mov     esi, DWORD[ebp+8]
    mov     DWORD[eax+8], esi
    
    mov     esp, ebp
    pop     ebp
    ret

insertSorted: ; void insertSorted (struct dllheader *L, int val)
    push    ebp
    mov     ebp, esp

    mov     ebx, DWORD[ebp+12]

    mov     eax, DWORD[ebp+8]
    mov     eax, DWORD[eax+8]
    test    eax, eax
    jne     insSortElse
        push    ebx
        push    DWORD[ebp+8]
        call    insertFront
        add     esp, 8
        jmp     insSortEnd
    insSortElse:
        mov     eax, DWORD[ebp+8]
        mov     eax, DWORD[eax] 
        insSortTop:
        cmp     DWORD[eax], 0
        je      insSortBot
            cmp     ebx, DWORD[eax+8]
            jg      insSortIf
                push    eax
                push    ebx
                push    DWORD[ebp+8]
                call    insertBefore
                add     esp, 12
                jmp     insSortEnd
            insSortIf:
            mov     eax, DWORD[eax] 
        insSortBot:
        push    ebx
        push    DWORD[ebp+8]
        call    insertBack
        add     esp, 8
    insSortEnd:
    
    mov     esp, ebp
    pop     ebp
    ret

insertFront: ; void insertFront (struct dllheader *L, int num)
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+12]
    call    makenode
    add     esp, 4
    mov     ecx, eax

    mov     eax, DWORD[ebp+8]
    mov     ebx, DWORD[eax] 
    mov     DWORD[ecx], ebx

    test    ebx, ebx
    je      insFrontElse
        mov     edx, DWORD[ecx]
        mov     DWORD[edx+4], ecx
        jmp     insFrontEnd
    insFrontElse:
        mov     DWORD[eax+4], ecx
    insFrontEnd:

    mov     DWORD[eax], ecx
    inc     DWORD[eax+8]

    mov     esp, ebp
    pop     ebp
    ret

insertBack: ; void insertBack (struct dllheader *L, int num)
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+12]
    call    makenode
    add     esp, 4
    mov     ecx, eax
    
    mov     eax, DWORD[ebp+8]
    mov     ebx, DWORD[eax+4]
    cmp     ebx, 0
    jne     insBackElse
        mov     DWORD[eax], ecx
        mov     DWORD[eax+4], ecx
        jmp     insBackEnd
    insBackElse: 
        ;mov     ebx, DWORD[ebx]
        mov     DWORD[ebx], ecx
        mov     DWORD[ecx+4], eax
        add     DWORD[ecx+4], 4
        mov     ebx, DWORD[eax+4]
        mov     DWORD[ebx], ecx
    insBackEnd:
    inc     DWORD[eax+8]

    mov     esp, ebp
    pop     ebp
    ret

insertAfter: ; void insertAfter (struct dllheader *L, int num, struct lnode *p)
    push    ebp
    mov     ebp, esp

    mov     eax, DWORD[ebp+12]
    cmp     DWORD[eax], 0
    jne     insAfterElse
        push    DWORD[ebp+12]
        push    DWORD[ebp+8]
        call    insertBack
        add     esp, 8
        jmp     insAfterEnd  
    insAfterElse:
        push    DWORD[ebp+12]
        call    makenode
        add     esp, 4

        mov     ebx, DWORD[ebp+16]
        mov     DWORD[eax+4], ebx
        mov     ebx, DWORD[ebx]
        mov     DWORD[eax], ebx

        mov     DWORD[ebx+4], eax
        mov     ebx, DWORD[ebp+16]
        mov     DWORD[ebx], eax
        mov     ebx, DWORD[ebp+8]
        inc     DWORD[ebx+8]  
    insAfterEnd:
    mov     esp, ebp
    pop     ebp
    ret 

insertBefore: ; void insertBefore (struct dllheader *L, int num, structlode *p)
    push    ebp
    mov     ebp, esp

    mov     eax, DWORD[ebp+16]
    cmp     DWORD[eax+4], 0
    jne     insBeforeElse
        push    DWORD[ebp+12]
        push    DWORD[ebp+8]
        call    insertFront
        add     esp, 8
        jmp     insBeforeEnd
    insBeforeElse:
        push    DWORD[ebp+12]
        call    makenode
        add     esp, 4

        mov     ecx, eax
        mov     eax, DWORD[ebp+16]
        mov     DWORD[ecx], eax
        mov     ebx, DWORD[eax+4]
        mov     DWORD[eax+4], ebx

        mov     DWORD[ebx], ecx
        mov     ebx, DWORD[eax+4]
        mov     DWORD[ebx], ecx
        mov     ebx, DWORD[ebp+8]
        inc     DWORD[ebx+8]
    insBeforeEnd:
    mov     esp, ebp
    pop     ebp
    ret

isInList: ; int isInList (struct dllheader *L, int num)

printerF: ; void printerF (struct dllheader *alist)
    push    ebp
    mov     ebp, esp

    sub     esp, 4

    mov     eax, DWORD[ebp+8]
    mov     eax, DWORD[eax]
    mov     DWORD[ebp-4], eax
    
    printFTop:
    mov     eax, DWORD[ebp-4]
    cmp     eax, 0
    je      printFBot
        push    DWORD[eax+8]
        push    printformat
        call    printf
        add     esp, 8
        mov     eax, DWORD[ebp-4]
        mov     eax, DWORD[eax]
        mov     DWORD[ebp-4], eax
        jmp     printFTop
    printFBot: 

    mov     esp, ebp
    pop     ebp
    ret

printerR: ; void printerR (struct dllheader *alist)

; vim:ft=nasm
