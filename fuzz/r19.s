        addi x31, x0, 0x80
        lbu x2, 25(x31)
        slti x5, x3, -7
        sltu x6, x5, x2
        sh x1, 24(x31)
        bne x2, x8, L0_19
        sw x7, 0(x31)
L0_19:
        sh x8, 38(x31)
        lui x3, 852268
        lui x2, 434794
        sll x2, x8, x1
        jal x2, L1_19
        bge x6, x7, L2_19
        beq x4, x2, L3_19
L1_19:
        addi x5, x3, 2047
L2_19:
        sltiu x3, x8, 2047
        lw x2, 24(x31)
        la x7, L4_19
        jalr x0, 0(x7)
L3_19:
        srl x8, x1, x3
        addi x3, x3, -100
L4_19:
        slli x4, x8, 4
        jal x3, L5_19
L5_19:
        sltiu x5, x1, -2048
        la x4, L6_19
        jalr x0, 0(x4)
L6_19:
        addi x5, x4, 1
        lui x3, 678228
        bltu x5, x5, L7_19
        auipc x8, 131008
        add x8, x2, x2
L7_19:
        srli x6, x6, 23
        blt x2, x8, L8_19
L8_19:
fin:    j    fin
