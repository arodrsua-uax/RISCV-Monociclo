        addi x31, x0, 0x80
        la x1, L0_2
        jalr x0, 0(x1)
L0_2:
        andi x5, x5, 5
        lh x7, 50(x31)
        bltu x6, x8, L1_2
        jal x1, L2_2
        jal x7, L3_2
        bne x3, x4, L4_2
L1_2:
        and x3, x6, x3
        xori x6, x6, 100
        la x3, L5_2
        jalr x0, 0(x3)
        sltiu x8, x4, 2047
L2_2:
        srai x6, x8, 29
        sb x8, 62(x31)
        jal x3, L6_2
        lb x5, 38(x31)
        sb x7, 39(x31)
        srli x2, x6, 0
        sub x1, x1, x5
        lw x3, 32(x31)
L3_2:
        add x7, x1, x1
        add x2, x2, x2
L4_2:
        sw x6, 32(x31)
L5_2:
        jal x3, L7_2
        sra x1, x4, x3
        sra x2, x5, x6
        slti x1, x5, -100
        sh x4, 10(x31)
        addi x1, x8, -1
        sh x6, 18(x31)
        ori x7, x1, -2048
L6_2:
L7_2:
fin:    j    fin
