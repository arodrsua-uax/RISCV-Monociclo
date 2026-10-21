        addi x31, x0, 0x80
        auipc x7, 1012005
        auipc x4, 970101
        blt x3, x1, L0_10
        andi x6, x1, -100
        lb x7, 36(x31)
        andi x5, x6, -1
        bne x8, x7, L1_10
L0_10:
        and x4, x5, x6
        srl x8, x7, x8
L1_10:
        lbu x3, 28(x31)
        add x8, x5, x2
        bne x7, x6, L2_10
        sub x8, x3, x4
        xori x8, x4, -7
L2_10:
        lui x2, 559996
        and x3, x8, x6
        srl x1, x6, x6
        xori x3, x7, 2047
        srl x5, x8, x8
        srli x7, x3, 26
        xori x8, x3, -2048
        la x7, L3_10
        jalr x0, 0(x7)
        bge x2, x1, L4_10
        sra x8, x8, x3
        slti x8, x6, -7
        lb x6, 19(x31)
        addi x4, x8, 0
        la x7, L5_10
        jalr x0, 0(x7)
        xor x2, x1, x2
        sltiu x8, x3, 100
L3_10:
L4_10:
L5_10:
fin:    j    fin
