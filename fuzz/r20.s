        addi x31, x0, 0x80
        jal x3, L0_20
L0_20:
        lw x6, 20(x31)
        addi x2, x3, 100
        lb x4, 25(x31)
        jal x6, L1_20
        srl x8, x7, x2
L1_20:
        or x2, x2, x4
        sh x5, 20(x31)
        jal x5, L2_20
        bne x4, x1, L3_20
L2_20:
        lhu x5, 16(x31)
        sltiu x8, x3, -7
        andi x7, x2, -1
        lhu x4, 14(x31)
        or x7, x3, x3
        xor x1, x6, x7
        lui x1, 344132
L3_20:
        srli x1, x2, 6
        addi x5, x1, 0
        lui x1, 328336
        lbu x3, 39(x31)
        addi x7, x2, 5
        beq x5, x3, L4_20
        bgeu x2, x8, L5_20
        xor x7, x2, x5
L4_20:
        lh x2, 0(x31)
L5_20:
        blt x5, x7, L6_20
        jal x2, L7_20
L6_20:
        slli x2, x6, 0
L7_20:
        addi x1, x1, 5
fin:    j    fin
