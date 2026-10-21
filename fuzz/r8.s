        addi x31, x0, 0x80
        sltu x3, x4, x1
        or x4, x7, x1
        srli x7, x8, 12
        bge x2, x8, L0_8
L0_8:
        xor x7, x8, x7
        lw x2, 48(x31)
        sltiu x1, x6, 5
        srai x4, x3, 4
        or x3, x8, x8
        xori x3, x3, 1
        ori x8, x4, -7
        lui x2, 461279
        jal x5, L1_8
        xori x5, x7, -7
        bne x7, x2, L2_8
L1_8:
        lw x4, 20(x31)
        sltu x6, x3, x7
        sra x8, x7, x7
L2_8:
        sub x1, x2, x2
        lui x3, 1023911
        la x2, L3_8
        jalr x0, 0(x2)
L3_8:
        jal x6, L4_8
        auipc x5, 737032
        sltiu x8, x4, 0
        sra x3, x3, x6
        addi x4, x4, 2047
        sh x2, 12(x31)
        slli x8, x2, 30
        bge x4, x1, L5_8
L4_8:
        addi x4, x1, 0
L5_8:
fin:    j    fin
