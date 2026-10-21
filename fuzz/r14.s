        addi x31, x0, 0x80
        srl x4, x5, x5
        addi x8, x5, 2047
        lb x7, 15(x31)
        ori x6, x5, 100
        bgeu x3, x3, L0_14
        lh x1, 8(x31)
L0_14:
        addi x5, x4, -100
        la x8, L1_14
        jalr x0, 0(x8)
        sub x6, x3, x2
        srai x4, x5, 28
        srli x5, x2, 7
        xor x2, x1, x3
        srl x2, x7, x8
        sltu x8, x5, x8
        addi x5, x8, -100
L1_14:
        bge x2, x3, L2_14
        xori x1, x7, -100
L2_14:
        sh x8, 32(x31)
        lui x1, 984104
        sub x1, x4, x5
        srl x5, x6, x5
        la x4, L3_14
        jalr x0, 0(x4)
L3_14:
        slti x5, x3, 5
        lhu x5, 46(x31)
        jal x3, L4_14
        blt x8, x7, L5_14
L4_14:
        slti x6, x8, 0
L5_14:
        jal x8, L6_14
        sub x3, x4, x1
        xor x8, x8, x3
L6_14:
fin:    j    fin
