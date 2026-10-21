        addi x31, x0, 0x80
        xori x5, x7, 5
        xori x5, x4, 5
        xor x6, x3, x5
        or x5, x1, x3
        bgeu x1, x8, L0_16
        lhu x4, 38(x31)
        addi x6, x8, -100
        sra x5, x1, x5
        beq x6, x4, L1_16
        ori x8, x8, 1
L0_16:
        slli x8, x8, 0
        slli x8, x2, 31
        la x4, L2_16
        jalr x0, 0(x4)
        beq x1, x7, L3_16
        srai x2, x4, 20
L1_16:
        sub x4, x1, x7
        jal x2, L4_16
        sltu x3, x5, x4
L2_16:
        srl x4, x2, x2
        xori x1, x7, 2047
        srli x1, x1, 1
        ori x7, x2, 5
L3_16:
        lhu x2, 58(x31)
        bne x3, x3, L5_16
        andi x7, x3, 100
        bge x4, x7, L6_16
        srai x5, x2, 4
        sb x8, 30(x31)
        srai x8, x3, 31
        sb x2, 40(x31)
L4_16:
L5_16:
L6_16:
fin:    j    fin
