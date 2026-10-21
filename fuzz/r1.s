        addi x31, x0, 0x80
        sub x5, x2, x8
        sh x7, 26(x31)
        add x7, x7, x1
        lhu x4, 12(x31)
        jal x1, L0_1
L0_1:
        lw x7, 24(x31)
        sb x4, 56(x31)
        auipc x6, 484162
        sh x1, 52(x31)
        auipc x2, 389873
        sh x2, 42(x31)
        la x7, L1_1
        jalr x0, 0(x7)
        jal x4, L2_1
        lb x7, 4(x31)
        sh x7, 22(x31)
        bgeu x6, x2, L3_1
        lui x3, 824715
        sh x1, 38(x31)
        la x7, L4_1
        jalr x0, 0(x7)
        or x1, x4, x4
        slti x6, x8, -7
        lw x7, 16(x31)
        auipc x7, 117699
        slti x4, x7, 2047
        addi x6, x8, 0
        lbu x3, 11(x31)
        sh x1, 8(x31)
L1_1:
        add x5, x4, x5
L2_1:
        lhu x5, 8(x31)
L3_1:
        andi x5, x5, 2047
L4_1:
fin:    j    fin
