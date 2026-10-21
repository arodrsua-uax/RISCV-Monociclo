        addi x1, x0, 25
        addi x2, x0, -7
        nop
        nop
        nop
        sw   x1, 8(x0)
        sw   x2, 12(x0)
        nop
        nop
        nop
        lw   x3, 8(x0)
        lw   x4, 12(x0)
        nop
        nop
        nop
        add  x5, x3, x4
        addi x6, x0, 8
        nop
        nop
        nop
        sw   x5, -4(x6)
        lb   x7, 12(x0)
        nop
        nop
        nop
fin:    j    fin