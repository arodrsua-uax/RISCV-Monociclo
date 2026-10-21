        addi x1, x0, 5
        addi x2, x1, 3
        add  x3, x1, x2
        sub  x4, x3, x1
        and  x5, x4, x3
        or   x6, x5, x2
        sw   x6, 0(x0)
        lw   x7, 0(x0)
        nop
        add  x8, x7, x7
        addi x9, x0, 4
        sw   x9, 4(x0)
        addi x10, x9, 1
        beq  x10, x10, ok
        addi x11, x0, 99
        addi x12, x0, 99
ok:     addi x13, x0, 1
        addi x14, x13, 1
        addi x15, x14, 1
fin:    j    fin