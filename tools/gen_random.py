#!/usr/bin/env python3
"""Genera un programa RV32I aleatorio valido (sin bucles, memoria acotada)."""
import random, sys

seed = int(sys.argv[1]); n = int(sys.argv[2]) if len(sys.argv) > 2 else 60
random.seed(seed)
R = lambda: f"x{random.randint(1, 8)}"          # registros de trabajo
IMM = lambda: random.choice([0, 1, -1, 5, -7, 100, -100, 2047, -2048])

lines = ["        addi x31, x0, 0x80"]            # base de datos, no se toca
labels = []                                     # etiquetas pendientes de definir
count = 0
def new_label():
    labels.append(f"L{len(labels)}_{seed}")
    return labels[-1]

for i in range(n):
    # Etiquetas pendientes que se definen aqui con cierta probabilidad
    if labels and random.random() < 0.3:
        pend = [l for l in labels if l not in [x.split(":")[0] for x in lines]]
        if pend:
            lines.append(f"{pend[0]}:")
    k = random.random()
    if k < 0.25:
        op = random.choice(["add","sub","and","or","xor","slt","sltu","sll","srl","sra"])
        lines.append(f"        {op} {R()}, {R()}, {R()}")
    elif k < 0.45:
        op = random.choice(["addi","andi","ori","xori","slti","sltiu"])
        lines.append(f"        {op} {R()}, {R()}, {IMM()}")
    elif k < 0.50:
        op = random.choice(["slli","srli","srai"])
        lines.append(f"        {op} {R()}, {R()}, {random.randint(0,31)}")
    elif k < 0.55:
        lines.append(f"        lui {R()}, {random.randint(0, 0xFFFFF)}")
    elif k < 0.58:
        lines.append(f"        auipc {R()}, {random.randint(0, 0xFFFFF)}")
    elif k < 0.70:
        op, al = random.choice([("lw",4),("lh",2),("lhu",2),("lb",1),("lbu",1)])
        lines.append(f"        {op} {R()}, {random.randrange(0, 64, al)}(x31)")
    elif k < 0.80:
        op, al = random.choice([("sw",4),("sh",2),("sb",1)])
        lines.append(f"        {op} {R()}, {random.randrange(0, 64, al)}(x31)")
    elif k < 0.90:
        op = random.choice(["beq","bne","blt","bge","bltu","bgeu"])
        lines.append(f"        {op} {R()}, {R()}, {new_label()}")
    elif k < 0.95:
        lines.append(f"        jal {R()}, {new_label()}")
    else:
        l = new_label(); r = R()
        lines.append(f"        la {r}, {l}")
        lines.append(f"        jalr x0, 0({r})")

# Definir todas las etiquetas que queden pendientes
defined = {x.split(":")[0] for x in lines if x.endswith(":")}
for l in labels:
    if l not in defined:
        lines.append(f"{l}:")
        defined.add(l)
lines.append("fin:    j    fin")
print("\n".join(lines))