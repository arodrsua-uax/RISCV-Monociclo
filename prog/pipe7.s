        lui  x1, 0x12345
        addi x1, x1, 0x678
        jal  x2, f
        addi x9, x0, 1
f:      add  x3, x2, x2
        la   x4, g
        jalr x5, 0(x4)
        addi x9, x0, 2
g:      add  x6, x5, x5
        sw   x6, 0(x0)
fin:    j    fin