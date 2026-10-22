#!/usr/bin/env python3
"""Ensambla con RARS y sustituye marcadores por instrucciones que RARS no conoce.

Uso: tools/asm.py prog/x.s mem/x.hex

RARS no tiene mret ni permite .word en .text, asi que en el .s se escribe
addi x0, x0, 0x7fN (un NOP) y aqui se cambia por la palabra real.
"""
import subprocess, sys

MARCAS = {
    0x7f100013: 0x30200073,   # addi x0, x0, 0x7f1 -> mret
    0x7f200013: 0xFFFFFFFF,   # addi x0, x0, 0x7f2 -> instruccion ilegal
    0x7f300013: 0x10500073,   # addi x0, x0, 0x7f3 -> wfi
    0x7f400013: 0x0000100F,   # addi x0, x0, 0x7f4 -> fence.i
    0x7f500013: 0x00000000,   # addi x0, x0, 0x7f5 -> palabra a cero (ilegal)
    0x7f600013: 0x402091B3,   # addi x0, x0, 0x7f6 -> sll x3 con funct7 = 0100000 (ilegal)
}

src, dst = sys.argv[1], sys.argv[2]
subprocess.run(["java", "-jar", "tools/rars.jar", "nc", "mc", "CompactTextAtZero",
                "a", "dump", ".text", "HexText", dst, src], check=True)
palabras = [int(l, 16) for l in open(dst) if l.strip()]
with open(dst, "w") as f:
    for w in palabras:
        f.write(f"{MARCAS.get(w, w):08x}\n")
