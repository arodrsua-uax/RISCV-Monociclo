        addi x5, x0, 10      # contador
        addi x6, x0, 0       # suma
loop:   beq  x5, x0, fin
        add  x6, x6, x5
        addi x5, x5, -1
        j    loop
fin:    sw   x6, 0(x0)       # guarda la suma en la palabra 0
        lw   x7, 0(x0)       # la vuelve a leer
fin2:   j    fin2            # bucle final
