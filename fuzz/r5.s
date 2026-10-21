        addi x31, x0, 0x80
        lhu x1, 58(x31)
        sw x1, 20(x31)
        sll x4, x7, x2
        auipc x1, 454515
        andi x7, x3, 1
        sra x8, x3, x3
        add x4, x4, x3
        blt x6, x4, L0_5
        lh x3, 24(x31)
        blt x1, x6, L1_5
        jal x5, L2_5
L0_5:
        slti x1, x6, 1
        bge x6, x3, L3_5
        sw x5, 0(x31)
        xori x1, x7, 100
        bge x1, x3, L4_5
        la x2, L5_5
        jalr x0, 0(x2)
        jal x8, L6_5
        slti x5, x8, 1
        sh x5, 4(x31)
        la x4, L7_5
        jalr x0, 0(x4)
        lh x6, 34(x31)
        lui x5, 664377
        sb x3, 39(x31)
        add x2, x7, x1
L1_5:
        lhu x8, 52(x31)
L2_5:
        la x1, L8_5
        jalr x0, 0(x1)
        andi x3, x3, -100
L3_5:
        andi x1, x7, -7
L4_5:
        jal x3, L9_5
L5_5:
L6_5:
L7_5:
L8_5:
L9_5:
fin:    j    fin
