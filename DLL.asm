segment .data
    printformat     db  "%d -> ", 0, 0
    printform2      db  "%d", 10, 0
    scanformat      db  "%d", 0
    printNl         db  10, 0

segment .bss
    dllPointer      resd    1    
    numIn           resd    1

segment .text
    extern    printf
    extern    scanf
    extern    malloc
    global    main

main: 
    enter   0, 0
    pusha

    call    makelist
    mov     DWORD[dllPointer], eax

    topScan: 
    push    numIn
    push    scanformat
    call    scanf
    add     esp, 8 

    cmp     DWORD[numIn], 0
    jle     endScan
        push    DWORD[numIn]
        push    DWORD[dllPointer]
        call    insertSorted
        add     esp, 8
        jmp     topScan
    endScan:
    jmp     bot


    push    10 
    push    DWORD[dllPointer]
    ;call    insertSorted
    ;call    insertBack
    call    insertFront
    add     esp, 8

    push    14
    push    DWORD[dllPointer]
    ;call    insertSorted
    ;call    insertBack
    call    insertFront
    add     esp, 8

    push    12
    push    DWORD[dllPointer]
    ;call    insertSorted
    ;call    insertBack
    call    insertFront
    add     esp, 8

    push    30
    push    DWORD[dllPointer]
    ;call    insertSorted
    ;call    insertBack
    call    insertFront
    add     esp, 8

bot:

    push    DWORD[dllPointer]
    call    printerF
    add     esp, 4

    push    DWORD[dllPointer]
    call    printerR
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
    jnz     insSortElse
        push    ebx
        push    DWORD[ebp+8]
        call    insertFront
        add     esp, 8
        jmp     insSortEnd
    insSortElse:
        mov     eax, DWORD[ebp+8]
        mov     eax, DWORD[eax] 
        insSortTop:
        ;cmp     DWORD[eax], 0
        cmp     eax, 0
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
            jmp     insSortTop
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
        mov     ebx, DWORD[ebp+8]
        mov     ebx, DWORD[ebx+4]
        mov     DWORD[ebx], ecx
        mov     eax, DWORD[eax+4]
        mov     DWORD[ecx+4], eax

        mov     ebx, DWORD[ebp+8]
        mov     DWORD[ebx+4], ecx
    insBackEnd:
    mov     eax, DWORD[ebp+8]
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
        mov     ecx, eax

        mov     ebx, DWORD[ebp+16]
        mov     DWORD[ecx+4], ebx
        mov     ebx, DWORD[ebx]
        mov     Dword[ecx], ebx

        mov     ebx, DWORD[ebx+4]
        mov     DWORD[ebx], ecx
        mov     ebx, DWORD[ebp+16]
        mov     DWORD[ebx], ecx

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
        mov     DWORD[ecx+4], ebx

        mov     eax, DWORD[ebp+16]
        mov     eax, DWORD[eax+4]
        mov     DWORD[eax], ecx
        mov     eax, DWORD[ebp+16]
        mov     DWORD[eax+4], ecx
        
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
        mov     ebx, DWORD[eax]
        neg     ebx
        sbb     ebx, ebx
        inc     ebx
        shl     ebx, 3
        lea     ebx, [printformat+ebx]
        push    ebx
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
    push    ebp
    mov     ebp, esp

    sub     esp, 4

    mov     eax, DWORD[ebp+8]
    mov     eax, DWORD[eax+4]
    mov     DWORD[ebp-4], eax
    
    printRTop:
    mov     eax, DWORD[ebp-4]
    cmp     eax, 0
    je      printRBot
        push    DWORD[eax+8]
        mov     ebx, DWORD[eax+4]
        neg     ebx
        sbb     ebx, ebx
        inc     ebx
        shl     ebx, 3
        lea     ebx, [printformat+ebx]
        push    ebx
        call    printf
        add     esp, 8
        mov     eax, DWORD[ebp-4]
        mov     eax, DWORD[eax+4]
        mov     DWORD[ebp-4], eax
        jmp     printRTop
    printRBot: 

    push    printNl
    call    printf
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; vim:ft=nasm
