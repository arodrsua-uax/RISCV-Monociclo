        addi x31, x0, 0x80
        srli x5, x3, 11
        beq x6, x8, L0_9
        srl x1, x7, x3
        srai x7, x3, 10
L0_9:
        srl x2, x7, x2
        or x7, x2, x5
        ori x1, x4, 0
        sltu x8, x3, x1
        sw x1, 12(x31)
        or x6, x1, x2
        jal x2, L1_9
        lui x4, 881029
L1_9:
        sub x3, x3, x1
        auipc x3, 562688
        auipc x1, 254459
        andi x3, x1, 100
        lui x2, 728127
        blt x8, x4, L2_9
        la x1, L3_9
        jalr x0, 0(x1)
        lw x7, 12(x31)
L2_9:
        ori x2, x5, -7
L3_9:
        sw x7, 52(x31)
        sw x2, 52(x31)
        sltu x6, x6, x3
        xor x1, x1, x3
        sub x3, x1, x1
        sltu x5, x1, x6
        srli x3, x2, 18
        sll x3, x7, x3
        slti x8, x6, 1
fin:    j    fin
