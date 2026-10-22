# Excepciones: el manejador anota mcause, mtval y mepc a partir de 0x40 y
# vuelve a la instruccion siguiente. Ensamblar con tools/asm.py
        la   t0, handler
        csrrw x0, 0x305, t0       # mtvec = handler
        addi s0, x0, 0x40         # puntero del registro de excepciones
        addi t1, x0, 0x55
        sw   t1, 0(x0)            # mem[0] = 0x55
        csrrsi x0, 0x300, 8       # mstatus.MIE = 1
e1:     ecall                     # 11
e2:     ebreak                    # 3
e3:     addi x0, x0, 0x7f2        # 0xffffffff: ilegal (2)
e4:     csrrw x0, 0xF14, t1       # escribir mhartid: ilegal (2)
e5:     csrrs x0, 0x7C0, x0       # CSR que no existe: ilegal (2)
e6:     addi x0, x0, 0x7f5        # 0x00000000: ilegal (2)
        addi t0, x0, 2
e7:     lw   a2, 0(t0)            # carga desalineada (4), mtval = 2; a2 no cambia
e8:     sw   t0, 1(x0)            # store desalineado (6), mtval = 1; mem no cambia
e9:     lh   a3, 1(x0)            # carga desalineada (4), mtval = 1
        la   t0, tgt
e10:    jalr a4, 2(t0)            # destino desalineado (0), mtval = tgt+2; a4 no cambia
e11:    ecall                     # 11, con un lw detras y su uso esperando en ID
        lw   t2, 0(x0)            # se ejecuta al volver: 0x55
        addi t3, t2, 1            # 0x56
e12:    addi x0, x0, 0x7f6        # sll x3 con funct7 ilegal (2): x3 no cambia
        beq  x0, x0, skip
        ecall                     # en la sombra del salto: no hay excepcion
        ecall
skip:   csrrs a5, 0x300, x0       # mstatus = 0x1888 (mret repone MIE)
        lw   a6, 0(x0)            # 0x55
        addi a7, x0, 1            # llega aqui
fin:    j    fin
tgt:    addi x0, x0, 0
handler:
        csrrs s1, 0x342, x0       # mcause
        csrrs s2, 0x343, x0       # mtval
        csrrs s3, 0x341, x0       # mepc
        sw   s1, 0(s0)
        sw   s2, 4(s0)
        sw   s3, 8(s0)
        addi s0, s0, 12
        csrrs s4, 0x300, x0       # mstatus dentro del manejador = 0x1880
        addi s3, s3, 4
        csrrw x0, 0x341, s3       # vuelve a la instruccion siguiente
        addi x0, x0, 0x7f1        # mret
