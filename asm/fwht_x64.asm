; SPDX-License-Identifier: Apache-2.0
; Copyright (c) 2026 Alexander Stephen Donahue
;
; Exact 64-bit integer Fast Walsh-Hadamard Transform kernels (16-point and 32-point)
; for 4-qubit and 5-qubit Pauli expectation verification.
;
; Dual-ABI (Windows x64 & Linux System V AMD64) using exclusively caller-saved
; baseline x86-64 registers (zero stack frame, zero callee-saved clobbers).
;
; C prototypes:
;   void fwht16_i64_asm(int64_t *buf);
;   void fwht32_i64_asm(int64_t *buf);

default rel

%ifdef WIN64
  %define ARG1 rcx
%else
  %define ARG1 rdi
%endif

%macro BFLY 2
    mov rax, [r10 + (%1)*8]
    mov rdx, [r10 + (%2)*8]
    mov r8,  rax
    add rax, rdx
    sub r8,  rdx
    mov [r10 + (%1)*8], rax
    mov [r10 + (%2)*8], r8
%endmacro

%macro FWHT16_BODY 0
    ; Stage 1: stride 1
    BFLY 0, 1
    BFLY 2, 3
    BFLY 4, 5
    BFLY 6, 7
    BFLY 8, 9
    BFLY 10, 11
    BFLY 12, 13
    BFLY 14, 15
    ; Stage 2: stride 2
    BFLY 0, 2
    BFLY 1, 3
    BFLY 4, 6
    BFLY 5, 7
    BFLY 8, 10
    BFLY 9, 11
    BFLY 12, 14
    BFLY 13, 15
    ; Stage 3: stride 4
    BFLY 0, 4
    BFLY 1, 5
    BFLY 2, 6
    BFLY 3, 7
    BFLY 8, 12
    BFLY 9, 13
    BFLY 10, 14
    BFLY 11, 15
    ; Stage 4: stride 8
    BFLY 0, 8
    BFLY 1, 9
    BFLY 2, 10
    BFLY 3, 11
    BFLY 4, 12
    BFLY 5, 13
    BFLY 6, 14
    BFLY 7, 15
%endmacro

section .text
global fwht16_i64_asm
global fwht32_i64_asm

align 16
fwht16_i64_asm:
    mov r10, ARG1
    FWHT16_BODY
    ret

align 16
fwht32_i64_asm:
    mov r10, ARG1
    ; Lower half (0..15)
    FWHT16_BODY
    ; Upper half (16..31)
    add r10, 16*8
    FWHT16_BODY
    ; Stage 5: stride 16 across halves
    sub r10, 16*8
    BFLY 0, 16
    BFLY 1, 17
    BFLY 2, 18
    BFLY 3, 19
    BFLY 4, 20
    BFLY 5, 21
    BFLY 6, 22
    BFLY 7, 23
    BFLY 8, 24
    BFLY 9, 25
    BFLY 10, 26
    BFLY 11, 27
    BFLY 12, 28
    BFLY 13, 29
    BFLY 14, 30
    BFLY 15, 31
    ret

%ifndef WIN64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
