        addi x31, x0, 0x80
        sltiu x3, x4, -1
        bgeu x3, x3, L0_13
L0_13:
        bgeu x5, x1, L1_13
        bltu x1, x5, L2_13
        xor x8, x7, x3
        andi x8, x7, 100
        lw x6, 32(x31)
        auipc x3, 923543
        andi x5, x4, -1
        xori x5, x5, -100
        auipc x4, 494253
        sw x2, 52(x31)
        la x7, L3_13
        jalr x0, 0(x7)
L1_13:
        addi x4, x3, 2047
        bgeu x5, x3, L4_13
        sh x6, 24(x31)
        lbu x3, 30(x31)
        sra x1, x1, x6
        auipc x3, 619341
L2_13:
        sb x2, 28(x31)
L3_13:
        slti x1, x8, 100
        lui x3, 651347
L4_13:
        ori x2, x8, -2048
        beq x6, x6, L5_13
L5_13:
        auipc x8, 467775
        addi x7, x3, -1
        lh x5, 54(x31)
        andi x5, x7, 5
        ori x7, x8, 1
        add x5, x4, x8
fin:    j    fin
