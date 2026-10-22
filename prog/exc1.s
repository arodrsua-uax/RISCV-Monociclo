# Instrucciones CSR (sin excepciones). Ensamblar con tools/asm.py
        addi t1, x0, 0x55
        csrrw x0, 0x340, t1       # mscratch = 0x55 (t1 por forwarding)
        csrrs t2, 0x340, x0       # t2 = 0x55
        addi t3, t2, 1            # 0x56: usa el CSR leido justo antes (espera)
        csrrsi x0, 0x340, 2       # mscratch = 0x57
        csrrci t4, 0x340, 1       # t4 = 0x57, mscratch = 0x56
        csrrwi t5, 0x340, 7       # t5 = 0x56, mscratch = 7
        csrrs t6, 0x340, x0       # t6 = 7
        add  s1, t6, t6           # 14
        csrrs a0, 0x301, x0       # misa = 0x40000100
        csrrs a1, 0xF14, x0       # mhartid = 0 (leer un CSR de solo lectura es legal)
        csrrsi x0, 0x300, 8       # mstatus.MIE = 1
        csrrs a2, 0x300, x0       # mstatus = 0x1808
        csrrw a3, 0x343, t1       # a3 = 0 (mtval anterior), mtval = 0x55
        csrrs a4, 0x343, x0       # 0x55
        csrrw x0, 0x305, t1       # mtvec = 0x55 -> se guarda 0x54 (modo directo)
        csrrs a5, 0x305, x0       # 0x54
        fence 15, 15              # fence: NOP
        addi x0, x0, 0x7f3        # wfi: NOP
        addi x0, x0, 0x7f4        # fence.i: NOP
        addi t0, x0, 100
        csrrwi x0, 0x340, 5       # uimm = 5 coincide con t0 (x5): no hay forwarding
        csrrs a7, 0x340, x0       # 5
        addi a6, x0, 1            # llega aqui
fin:    j    fin
