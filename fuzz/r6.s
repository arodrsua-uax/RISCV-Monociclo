        addi x31, x0, 0x80
        sw x8, 32(x31)
        and x8, x6, x6
        sh x8, 24(x31)
        sh x2, 24(x31)
        auipc x5, 184778
        blt x2, x6, L0_6
        bge x2, x4, L1_6
        sw x1, 24(x31)
        jal x8, L2_6
        jal x1, L3_6
        sltu x5, x6, x2
L0_6:
        bltu x4, x2, L4_6
        sltiu x4, x7, 2047
L1_6:
        lbu x1, 24(x31)
        slt x5, x6, x7
        sltiu x8, x1, -1
        sh x2, 56(x31)
L2_6:
        la x8, L5_6
        jalr x0, 0(x8)
        beq x7, x8, L6_6
        beq x4, x5, L7_6
        sw x1, 0(x31)
        ori x4, x5, -2048
        jal x5, L8_6
        jal x7, L9_6
        xori x8, x8, -1
        srai x8, x6, 23
        la x7, L10_6
        jalr x0, 0(x7)
        sltiu x7, x8, -1
        addi x8, x1, -1
L3_6:
        sw x6, 44(x31)
L4_6:
L5_6:
L6_6:
L7_6:
L8_6:
L9_6:
L10_6:
fin:    j    fin
