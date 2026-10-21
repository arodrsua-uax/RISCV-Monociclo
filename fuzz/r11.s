        addi x31, x0, 0x80
        srai x8, x8, 12
        srl x8, x3, x2
        andi x2, x1, -100
        la x3, L0_11
        jalr x0, 0(x3)
        beq x1, x1, L1_11
L0_11:
        add x8, x6, x8
        or x5, x8, x1
        srli x7, x2, 16
        xor x1, x2, x2
        bge x2, x1, L2_11
        or x1, x8, x7
        addi x4, x5, 100
L1_11:
        xori x2, x3, 5
        sll x8, x3, x4
        and x7, x7, x2
        la x1, L3_11
        jalr x0, 0(x1)
L2_11:
        la x5, L4_11
        jalr x0, 0(x5)
        and x7, x2, x1
        xor x1, x6, x5
        or x4, x1, x6
        srai x8, x3, 24
L3_11:
        or x4, x4, x3
        jal x4, L5_11
        xori x2, x7, 0
L4_11:
        xor x4, x7, x5
        jal x8, L6_11
L5_11:
        sub x3, x4, x8
        bltu x2, x5, L7_11
L6_11:
        jal x1, L8_11
L7_11:
        andi x1, x1, -1
L8_11:
fin:    j    fin
