        addi x31, x0, 0x80
        andi x7, x1, 1
        beq x6, x1, L0_7
        sub x7, x7, x2
L0_7:
        auipc x1, 259631
        lbu x1, 50(x31)
        srl x3, x5, x7
        xor x3, x2, x4
        lui x2, 124992
        srai x7, x6, 29
        srli x4, x3, 15
        xori x6, x8, -7
        srl x7, x3, x6
        slli x2, x6, 21
        lbu x8, 8(x31)
        jal x8, L1_7
        xor x8, x5, x7
        xori x6, x3, 1
        xor x3, x4, x7
        beq x3, x8, L2_7
        andi x7, x5, -100
        lb x4, 19(x31)
L1_7:
        or x1, x8, x3
L2_7:
        sltu x6, x6, x3
        lui x1, 957651
        sb x7, 50(x31)
        sltu x1, x4, x2
        addi x6, x1, 1
        sub x6, x1, x2
        lh x5, 44(x31)
        slli x8, x8, 30
fin:    j    fin
