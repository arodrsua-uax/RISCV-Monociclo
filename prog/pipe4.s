        addi x1, x0, 5
        addi x2, x0, 5
        nop
        nop
        nop
        beq  x1, x2, salto1
        addi x10, x0, 99
        addi x11, x0, 99
salto1:     addi x3, x0, 1
        nop
        nop
        nop
        bne  x1, x2, bad
        addi x4, x0, 2
        jal  x5, salto3
        addi x12, x0, 99
        addi x13, x0, 99
salto3:     addi x6, x0, 0x5C
        nop
        nop
        nop
        jalr x7, 1(x6)
        addi x14, x0, 99
        addi x8, x0, 7
fin:    j    fin
bad:    addi x15, x0, 99
        j    bad