; # *****************************************
; # CONFIDENTIAL SOURCE CODE, DO NOT DISTRIBUTE!
; # IN SUBMISSION, ASPLOS 2024.
; # *****************************************
; #     Project:        PathFinder, PHR Attack Proof-of-Concept (PoC)
; #     Author:         Hosein Yavarzadeh
; #     Email:          hyavarzadeh@ucsd.edu
; #     Affiliation:    University of California, San Diego (UCSD)
; # *****************************************
; --------------------- 
; ---  open syscall for enabling ibpb ---
; push rdi
; mov rdi, msr_file_name
; mov rsi, 0
; mov rax, 2
; syscall
; mov [UserData+10000], rax
; pop rdi
; ---------------------

; --------------------- 
; ---  write syscall for enabling ibpb ---
; mov rdi, [UserData+10000]
; mov rsi, data
; mov rdx, 8
; mov r10, 73
; mov rax, syscall_pwrite
; syscall
; --------------------- 

; --------------------- 
; ---  exit syscall for enabling ibpb ---
; push rdi
; mov rdi, [UserData+10000]
; mov rax, syscall_close 
; syscall
; pop rdi
; ---------------------