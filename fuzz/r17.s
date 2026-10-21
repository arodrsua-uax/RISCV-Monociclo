        addi x31, x0, 0x80
        lui x5, 766768
        sltiu x5, x2, 0
        sltu x5, x6, x7
        srl x1, x3, x4
        srl x4, x6, x2
        bgeu x2, x5, L0_17
        lui x8, 296971
        slti x6, x1, -100
        slt x1, x8, x6
        sltu x4, x2, x4
        lui x6, 121869
L0_17:
        sw x3, 32(x31)
        jal x6, L1_17
L1_17:
        sra x5, x6, x1
        la x1, L2_17
        jalr x0, 0(x1)
        sltiu x1, x4, -7
L2_17:
        sb x8, 2(x31)
        lui x3, 845178
        la x7, L3_17
        jalr x0, 0(x7)
L3_17:
        la x3, L4_17
        jalr x0, 0(x3)
        jal x1, L5_17
        lui x6, 663038
L4_17:
        jal x2, L6_17
        ori x7, x8, 1
        lui x4, 471725
        andi x5, x1, 2047
        bne x7, x8, L7_17
L5_17:
        slli x4, x8, 20
        la x1, L8_17
        jalr x0, 0(x1)
        auipc x7, 112589
L6_17:
L7_17:
L8_17:
fin:    j    fin
