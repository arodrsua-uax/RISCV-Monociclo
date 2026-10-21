        addi x31, x0, 0x80
        la x1, L0_15
        jalr x0, 0(x1)
        or x1, x1, x3
        la x4, L1_15
        jalr x0, 0(x4)
L0_15:
        srli x5, x7, 16
        jal x4, L2_15
        sw x5, 52(x31)
L1_15:
        srli x8, x2, 29
        slti x6, x8, -100
        beq x8, x1, L3_15
L2_15:
        lui x1, 601079
        sub x2, x7, x1
L3_15:
        sb x5, 51(x31)
        srl x6, x2, x4
        slt x7, x8, x6
        sh x8, 18(x31)
        srli x1, x5, 5
        add x5, x3, x8
        bge x1, x1, L4_15
        sll x4, x8, x5
        lw x6, 48(x31)
        xor x8, x5, x1
        bge x1, x6, L5_15
        jal x1, L6_15
L4_15:
        srl x6, x6, x4
        ori x1, x6, 5
        and x2, x7, x6
        blt x2, x6, L7_15
        sb x8, 15(x31)
        sw x2, 16(x31)
        slli x4, x6, 23
L5_15:
L6_15:
L7_15:
fin:    j    fin
