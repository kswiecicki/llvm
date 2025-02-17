; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=X64

; These tests just check that the plumbing is in place for @llvm.bitreverse. The
; actual output is massive at the moment as llvm.bitreverse is not yet legal.

declare i32 @llvm.bitreverse.i32(i32) readnone
declare i64 @llvm.bitreverse.i64(i64) readnone
declare <4 x i32> @llvm.bitreverse.v4i32(<4 x i32>) readnone
declare i32 @llvm.bswap.i32(i32) readnone

; fold (bitreverse undef) -> undef
define i32 @test_undef() nounwind {
; X86-LABEL: test_undef:
; X86:       # %bb.0:
; X86-NEXT:    retl
;
; X64-LABEL: test_undef:
; X64:       # %bb.0:
; X64-NEXT:    retq
  %b = call i32 @llvm.bitreverse.i32(i32 undef)
  ret i32 %b
}

; fold (bitreverse (bitreverse x)) -> x
define i32 @test_bitreverse_bitreverse(i32 %a0) nounwind {
; X86-LABEL: test_bitreverse_bitreverse:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_bitreverse_bitreverse:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
  %b = call i32 @llvm.bitreverse.i32(i32 %a0)
  %c = call i32 @llvm.bitreverse.i32(i32 %b)
  ret i32 %c
}

; TODO: fold (bitreverse(srl (bitreverse c), x)) -> (shl c, x)
define i32 @test_bitreverse_srli_bitreverse(i32 %a0) nounwind {
; X86-LABEL: test_bitreverse_srli_bitreverse:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645135, %ecx # imm = 0xF0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993459, %ecx # imm = 0x33333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655744, %ecx # imm = 0x55555540
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655680, %eax # imm = 0x55555500
; X86-NEXT:    leal (%eax,%ecx,2), %eax
; X86-NEXT:    shrl $7, %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645121, %ecx # imm = 0xF0F0F01
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645120, %eax # imm = 0xF0F0F00
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993424, %ecx # imm = 0x33333310
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993408, %eax # imm = 0x33333300
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X86-NEXT:    leal (%eax,%ecx,2), %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_bitreverse_srli_bitreverse:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    bswapl %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X64-NEXT:    shll $4, %eax
; X64-NEXT:    shrl $4, %edi
; X64-NEXT:    andl $252645135, %edi # imm = 0xF0F0F0F
; X64-NEXT:    orl %eax, %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X64-NEXT:    shrl $2, %edi
; X64-NEXT:    andl $858993459, %edi # imm = 0x33333333
; X64-NEXT:    leal (%rdi,%rax,4), %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $1431655744, %ecx # imm = 0x55555540
; X64-NEXT:    shrl %eax
; X64-NEXT:    andl $1431655680, %eax # imm = 0x55555500
; X64-NEXT:    leal (%rax,%rcx,2), %eax
; X64-NEXT:    shrl $7, %eax
; X64-NEXT:    bswapl %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $252645121, %ecx # imm = 0xF0F0F01
; X64-NEXT:    shll $4, %ecx
; X64-NEXT:    shrl $4, %eax
; X64-NEXT:    andl $252645120, %eax # imm = 0xF0F0F00
; X64-NEXT:    orl %ecx, %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $858993424, %ecx # imm = 0x33333310
; X64-NEXT:    shrl $2, %eax
; X64-NEXT:    andl $858993408, %eax # imm = 0x33333300
; X64-NEXT:    leal (%rax,%rcx,4), %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X64-NEXT:    shrl %eax
; X64-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X64-NEXT:    leal (%rax,%rcx,2), %eax
; X64-NEXT:    retq
  %b = call i32 @llvm.bitreverse.i32(i32 %a0)
  %c = lshr i32 %b, 7
  %d = call i32 @llvm.bitreverse.i32(i32 %c)
  ret i32 %d
}

define i64 @test_bitreverse_srli_bitreverse_i64(i64 %a) nounwind {
; X86-LABEL: test_bitreverse_srli_bitreverse_i64:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645135, %ecx # imm = 0xF0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993459, %ecx # imm = 0x33333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655764, %eax # imm = 0x55555554
; X86-NEXT:    leal (%eax,%ecx,2), %eax
; X86-NEXT:    shrl %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645135, %ecx # imm = 0xF0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645127, %eax # imm = 0xF0F0F07
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993459, %ecx # imm = 0x33333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993457, %eax # imm = 0x33333331
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X86-NEXT:    leal (%eax,%ecx,2), %edx
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_bitreverse_srli_bitreverse_i64:
; X64:       # %bb.0:
; X64-NEXT:    bswapq %rdi
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    shrq $4, %rax
; X64-NEXT:    movabsq $1085102592571150095, %rcx # imm = 0xF0F0F0F0F0F0F0F
; X64-NEXT:    andq %rcx, %rax
; X64-NEXT:    andq %rcx, %rdi
; X64-NEXT:    shlq $4, %rdi
; X64-NEXT:    orq %rax, %rdi
; X64-NEXT:    movabsq $3689348814741910323, %rax # imm = 0x3333333333333333
; X64-NEXT:    movq %rdi, %rcx
; X64-NEXT:    andq %rax, %rcx
; X64-NEXT:    shrq $2, %rdi
; X64-NEXT:    andq %rax, %rdi
; X64-NEXT:    leaq (%rdi,%rcx,4), %rax
; X64-NEXT:    movabsq $6148914689804861440, %rcx # imm = 0x5555555500000000
; X64-NEXT:    andq %rax, %rcx
; X64-NEXT:    shrq %rax
; X64-NEXT:    movabsq $6148914685509894144, %rdx # imm = 0x5555555400000000
; X64-NEXT:    andq %rax, %rdx
; X64-NEXT:    leaq (%rdx,%rcx,2), %rax
; X64-NEXT:    shrq $33, %rax
; X64-NEXT:    bswapq %rax
; X64-NEXT:    movabsq $1085102592318504960, %rcx # imm = 0xF0F0F0F00000000
; X64-NEXT:    andq %rax, %rcx
; X64-NEXT:    shrq $4, %rax
; X64-NEXT:    movabsq $1085102557958766592, %rdx # imm = 0xF0F0F0700000000
; X64-NEXT:    andq %rax, %rdx
; X64-NEXT:    shlq $4, %rcx
; X64-NEXT:    orq %rdx, %rcx
; X64-NEXT:    movabsq $3689348813882916864, %rax # imm = 0x3333333300000000
; X64-NEXT:    andq %rcx, %rax
; X64-NEXT:    shrq $2, %rcx
; X64-NEXT:    movabsq $3689348805292982272, %rdx # imm = 0x3333333100000000
; X64-NEXT:    andq %rcx, %rdx
; X64-NEXT:    leaq (%rdx,%rax,4), %rax
; X64-NEXT:    movabsq $6148914691236517205, %rcx # imm = 0x5555555555555555
; X64-NEXT:    movq %rax, %rdx
; X64-NEXT:    andq %rcx, %rdx
; X64-NEXT:    shrq %rax
; X64-NEXT:    andq %rcx, %rax
; X64-NEXT:    leaq (%rax,%rdx,2), %rax
; X64-NEXT:    retq
    %1 = call i64 @llvm.bitreverse.i64(i64 %a)
    %2 = lshr i64 %1, 33
    %3 = call i64 @llvm.bitreverse.i64(i64 %2)
    ret i64 %3
}

; TODO: fold (bitreverse(shl (bitreverse c), x)) -> (srl c, x)
define i32 @test_bitreverse_shli_bitreverse(i32 %a0) nounwind {
; X86-LABEL: test_bitreverse_shli_bitreverse:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645135, %ecx # imm = 0xF0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993459, %ecx # imm = 0x33333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X86-NEXT:    leal (%eax,%ecx,4), %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    andl $5592405, %eax # imm = 0x555555
; X86-NEXT:    shll $6, %ecx
; X86-NEXT:    andl $-1431655808, %ecx # imm = 0xAAAAAA80
; X86-NEXT:    shll $8, %eax
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $986895, %ecx # imm = 0xF0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $135204623, %eax # imm = 0x80F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $3355443, %ecx # imm = 0x333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $36909875, %eax # imm = 0x2333333
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X86-NEXT:    leal (%eax,%ecx,2), %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_bitreverse_shli_bitreverse:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    bswapl %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X64-NEXT:    shll $4, %eax
; X64-NEXT:    shrl $4, %edi
; X64-NEXT:    andl $252645135, %edi # imm = 0xF0F0F0F
; X64-NEXT:    orl %eax, %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X64-NEXT:    shrl $2, %edi
; X64-NEXT:    andl $858993459, %edi # imm = 0x33333333
; X64-NEXT:    leal (%rdi,%rax,4), %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $5592405, %ecx # imm = 0x555555
; X64-NEXT:    shll $6, %eax
; X64-NEXT:    andl $-1431655808, %eax # imm = 0xAAAAAA80
; X64-NEXT:    shll $8, %ecx
; X64-NEXT:    orl %eax, %ecx
; X64-NEXT:    bswapl %ecx
; X64-NEXT:    movl %ecx, %eax
; X64-NEXT:    andl $986895, %eax # imm = 0xF0F0F
; X64-NEXT:    shll $4, %eax
; X64-NEXT:    shrl $4, %ecx
; X64-NEXT:    andl $135204623, %ecx # imm = 0x80F0F0F
; X64-NEXT:    orl %eax, %ecx
; X64-NEXT:    movl %ecx, %eax
; X64-NEXT:    andl $3355443, %eax # imm = 0x333333
; X64-NEXT:    shrl $2, %ecx
; X64-NEXT:    andl $36909875, %ecx # imm = 0x2333333
; X64-NEXT:    leal (%rcx,%rax,4), %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X64-NEXT:    shrl %eax
; X64-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X64-NEXT:    leal (%rax,%rcx,2), %eax
; X64-NEXT:    retq
  %b = call i32 @llvm.bitreverse.i32(i32 %a0)
  %c = shl i32 %b, 7
  %d = call i32 @llvm.bitreverse.i32(i32 %c)
  ret i32 %d
}

define i64 @test_bitreverse_shli_bitreverse_i64(i64 %a) nounwind {
; X86-LABEL: test_bitreverse_shli_bitreverse_i64:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $252645135, %ecx # imm = 0xF0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $858993459, %ecx # imm = 0x33333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $357913941, %ecx # imm = 0x15555555
; X86-NEXT:    andl $-1431655766, %eax # imm = 0xAAAAAAAA
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $235867919, %ecx # imm = 0xE0F0F0F
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    shrl $4, %eax
; X86-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $590558003, %ecx # imm = 0x23333333
; X86-NEXT:    shrl $2, %eax
; X86-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X86-NEXT:    leal (%eax,%ecx,4), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    andl $1431655765, %ecx # imm = 0x55555555
; X86-NEXT:    shrl %eax
; X86-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X86-NEXT:    leal (%eax,%ecx,2), %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_bitreverse_shli_bitreverse_i64:
; X64:       # %bb.0:
; X64-NEXT:    bswapq %rdi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X64-NEXT:    shll $4, %eax
; X64-NEXT:    shrl $4, %edi
; X64-NEXT:    andl $252645135, %edi # imm = 0xF0F0F0F
; X64-NEXT:    orl %eax, %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X64-NEXT:    shrl $2, %edi
; X64-NEXT:    andl $858993459, %edi # imm = 0x33333333
; X64-NEXT:    leal (%rdi,%rax,4), %eax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $357913941, %ecx # imm = 0x15555555
; X64-NEXT:    shrl %eax
; X64-NEXT:    andl $1431655765, %eax # imm = 0x55555555
; X64-NEXT:    leal (%rax,%rcx,2), %eax
; X64-NEXT:    shlq $33, %rax
; X64-NEXT:    bswapq %rax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $235867919, %ecx # imm = 0xE0F0F0F
; X64-NEXT:    shlq $4, %rcx
; X64-NEXT:    shrq $4, %rax
; X64-NEXT:    andl $252645135, %eax # imm = 0xF0F0F0F
; X64-NEXT:    orq %rcx, %rax
; X64-NEXT:    movl %eax, %ecx
; X64-NEXT:    andl $590558003, %ecx # imm = 0x23333333
; X64-NEXT:    shrq $2, %rax
; X64-NEXT:    andl $858993459, %eax # imm = 0x33333333
; X64-NEXT:    leaq (%rax,%rcx,4), %rax
; X64-NEXT:    movabsq $6148914691236517205, %rcx # imm = 0x5555555555555555
; X64-NEXT:    movq %rax, %rdx
; X64-NEXT:    andq %rcx, %rdx
; X64-NEXT:    shrq %rax
; X64-NEXT:    andq %rcx, %rax
; X64-NEXT:    leaq (%rax,%rdx,2), %rax
; X64-NEXT:    retq
    %1 = call i64 @llvm.bitreverse.i64(i64 %a)
    %2 = shl i64 %1, 33
    %3 = call i64 @llvm.bitreverse.i64(i64 %2)
    ret i64 %3
}

define <4 x i32> @test_demandedbits_bitreverse(<4 x i32> %a0) nounwind {
; X86-LABEL: test_demandedbits_bitreverse:
; X86:       # %bb.0:
; X86-NEXT:    pxor %xmm1, %xmm1
; X86-NEXT:    movdqa %xmm0, %xmm2
; X86-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; X86-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[3,2,1,0,4,5,6,7]
; X86-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,7,6,5,4]
; X86-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X86-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; X86-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,6,5,4]
; X86-NEXT:    packuswb %xmm2, %xmm0
; X86-NEXT:    movdqa %xmm0, %xmm1
; X86-NEXT:    psrlw $4, %xmm1
; X86-NEXT:    movdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; X86-NEXT:    pand %xmm2, %xmm1
; X86-NEXT:    pand %xmm2, %xmm0
; X86-NEXT:    psllw $4, %xmm0
; X86-NEXT:    por %xmm1, %xmm0
; X86-NEXT:    movdqa %xmm0, %xmm1
; X86-NEXT:    psrlw $2, %xmm1
; X86-NEXT:    movdqa {{.*#+}} xmm2 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; X86-NEXT:    pand %xmm2, %xmm1
; X86-NEXT:    pand %xmm2, %xmm0
; X86-NEXT:    psllw $2, %xmm0
; X86-NEXT:    por %xmm1, %xmm0
; X86-NEXT:    movdqa %xmm0, %xmm1
; X86-NEXT:    psrlw $1, %xmm1
; X86-NEXT:    movdqa {{.*#+}} xmm2 = [85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85]
; X86-NEXT:    pand %xmm2, %xmm1
; X86-NEXT:    pand %xmm2, %xmm0
; X86-NEXT:    paddb %xmm0, %xmm0
; X86-NEXT:    por %xmm1, %xmm0
; X86-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0
; X86-NEXT:    retl
;
; X64-LABEL: test_demandedbits_bitreverse:
; X64:       # %bb.0:
; X64-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; X64-NEXT:    vmovdqa {{.*#+}} xmm1 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm2
; X64-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240]
; X64-NEXT:    vpshufb %xmm2, %xmm3, %xmm2
; X64-NEXT:    vpsrlw $4, %xmm0, %xmm0
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa {{.*#+}} xmm1 = [0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15]
; X64-NEXT:    vpshufb %xmm0, %xmm1, %xmm0
; X64-NEXT:    vpor %xmm0, %xmm2, %xmm0
; X64-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; X64-NEXT:    retq
  %b = or <4 x i32> %a0, <i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648>
  %c = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %b)
  %d = and <4 x i32> %c, <i32 -2, i32 -2, i32 -2, i32 -2>
  ret <4 x i32> %d
}
