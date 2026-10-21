        addi x31, x0, 0x80
        srai x6, x3, 24
        slt x8, x5, x8
        lbu x4, 0(x31)
        lh x8, 46(x31)
        or x1, x4, x2
        lui x6, 848537
        sw x1, 4(x31)
        bgeu x4, x2, L0_12
        xori x2, x7, -1
        bltu x3, x1, L1_12
        lui x2, 839948
        lb x8, 49(x31)
        lw x4, 32(x31)
        sltiu x7, x5, 1
L0_12:
        ori x3, x1, -100
        slti x1, x4, -100
L1_12:
        sra x2, x4, x3
        xori x5, x8, 100
        sb x8, 47(x31)
        xori x8, x4, -1
        lui x3, 396848
        sra x1, x5, x6
        sb x1, 31(x31)
        la x3, L2_12
        jalr x0, 0(x3)
L2_12:
        sltiu x5, x2, 5
        lui x8, 741839
        jal x3, L3_12
        lw x5, 40(x31)
        lui x8, 448936
        lui x1, 7742
L3_12:
fin:    j    fin
