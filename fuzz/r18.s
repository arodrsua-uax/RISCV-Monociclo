        addi x31, x0, 0x80
        sll x6, x4, x4
        la x8, L0_18
        jalr x0, 0(x8)
L0_18:
        ori x4, x5, 1
        lh x4, 20(x31)
        sb x4, 63(x31)
        addi x6, x7, 5
        ori x5, x5, -7
        slti x3, x8, -1
        lb x3, 52(x31)
        auipc x4, 544018
        sltiu x8, x2, 2047
        sub x4, x2, x6
        jal x7, L1_18
        bgeu x1, x3, L2_18
        beq x8, x7, L3_18
        sltu x3, x5, x7
        ori x6, x5, -1
        lw x7, 16(x31)
        lb x1, 58(x31)
        sra x5, x7, x7
        auipc x7, 316391
L1_18:
        bne x6, x5, L4_18
        sw x6, 20(x31)
        lui x4, 549993
        sra x4, x3, x5
L2_18:
        ori x6, x2, -7
        sh x7, 52(x31)
        la x1, L5_18
        jalr x0, 0(x1)
L3_18:
        sltiu x1, x5, -100
L4_18:
        and x6, x3, x8
L5_18:
fin:    j    fin
