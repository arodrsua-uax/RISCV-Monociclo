        addi x1, x0, 9
        sw   x1, 0(x0)
        lw   x1, 0(x0)          # ebreak tiene rs2 = 1: provoca un lwStall inocuo
        ebreak                  # para aqui
        addi x2, x0, 77         # no debe ejecutarse
fin:    j    fin
