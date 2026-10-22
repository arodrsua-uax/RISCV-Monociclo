        addi x1, x0, 5
        fence 15, 15            # fence iorw, iorw
        addi x2, x1, 1          # 6: fence no rompe el forwarding
        beq  x0, x0, salta      # tomado: los dos ecall de detras se vacian
        ecall                   # en ID cuando el beq esta en EX (FlushE)
        ecall                   # en IF cuando el beq esta en EX (ValidD)
        addi x3, x0, 99
salta:  addi x3, x0, 3
        sw   x2, 0(x0)
        lw   x4, 0(x0)          # 6: justo antes del ecall, debe escribirse
        ecall                   # para aqui
        addi x5, x0, 55         # no debe ejecutarse
        sw   x5, 4(x0)          # no debe ejecutarse
fin:    j    fin
