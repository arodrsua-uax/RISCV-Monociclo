        addi x31, x0, 0x80
        srl x3, x6, x8
        lw x1, 60(x31)
        andi x4, x8, -2048
        bge x7, x3, L0_3
L0_3:
        srl x7, x1, x2
        la x1, L1_3
        jalr x0, 0(x1)
        xor x8, x7, x7
        bge x3, x6, L2_3
L1_3:
        or x5, x7, x5
        bltu x6, x7, L3_3
        jal x1, L4_3
        la x3, L5_3
        jalr x0, 0(x3)
        slti x2, x4, -7
L2_3:
        sll x2, x6, x2
        xor x7, x7, x2
L3_3:
        lw x7, 40(x31)
        jal x5, L6_3
        la x5, L7_3
        jalr x0, 0(x5)
L4_3:
        srl x1, x4, x7
L5_3:
        sltiu x1, x6, 100
        sltu x7, x8, x7
        lbu x2, 34(x31)
        sw x5, 52(x31)
        lui x6, 24028
        la x6, L8_3
        jalr x0, 0(x6)
L6_3:
        lh x1, 42(x31)
        lhu x5, 62(x31)
L7_3:
        add x6, x5, x8
L8_3:
        lh x6, 22(x31)
        slti x5, x5, -100
fin:    j    fin
