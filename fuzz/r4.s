        addi x31, x0, 0x80
        sub x7, x8, x3
        add x7, x5, x1
        srl x6, x5, x3
        blt x4, x1, L0_4
        blt x4, x3, L1_4
        lhu x2, 42(x31)
        lui x3, 518672
        srl x5, x1, x5
        bltu x4, x7, L2_4
        xori x3, x4, -7
L0_4:
        sw x1, 56(x31)
        slti x8, x6, -1
        sltu x4, x8, x5
L1_4:
        slti x6, x4, 100
L2_4:
        or x5, x4, x2
        sll x1, x1, x6
        blt x6, x1, L3_4
        andi x7, x2, -7
        blt x3, x5, L4_4
        la x6, L5_4
        jalr x0, 0(x6)
        xori x3, x6, 100
        auipc x8, 434606
        add x1, x1, x3
        la x1, L6_4
        jalr x0, 0(x1)
        lhu x1, 14(x31)
        xori x4, x8, 5
L3_4:
        addi x4, x7, 2047
L4_4:
        bne x8, x4, L7_4
L5_4:
        andi x4, x4, -100
        add x6, x2, x7
L6_4:
L7_4:
fin:    j    fin
