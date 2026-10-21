        addi x1, x0, 7
        sw   x1, 0(x0)
        lw   x2, 0(x0)
        add  x3, x2, x2
        lw   x4, 0(x0)
        sw   x4, 4(x0)
        lw   x5, 4(x0)
        addi x6, x5, 1
        lw   x7, 0(x0)
        beq  x7, x1, ok
        addi x8, x0, 99
        addi x9, x0, 99
ok:     addi x10, x0, 1
fin:    j    fin