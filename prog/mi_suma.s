    .text
    .globl _start

_start:

# -------------------------
# Inicialización
# -------------------------

    lui     x1, 0x12345
    addi    x1, x1, 0x678

    addi    x2, x0, 32      # base RAM = 0x20

    auipc   x3, 0

# -------------------------
# Operaciones aritméticas
# -------------------------

    addi    x4, x0, 25
    addi    x5, x0, 7

    add     x6, x4, x5
    sub     x7, x4, x5

# -------------------------
# Lógicas
# -------------------------

    and     x8,  x4, x5
    or      x9,  x4, x5
    xor     x10, x4, x5

    andi    x11, x4, 15
    ori     x12, x5, 32
    xori    x13, x4, -1

# -------------------------
# Desplazamientos
# -------------------------

    sll     x14, x5, x5
    srl     x15, x4, x5

    addi    x16, x0, -16
    sra     x17, x16, x5

    slli    x18, x5, 3
    srli    x19, x18, 2
    srai    x20, x16, 2

# -------------------------
# Comparaciones
# -------------------------

    slt     x21, x5, x4
    sltu    x22, x5, x4

    slti    x23, x5, 10
    sltiu   x24, x5, 10

# -------------------------
# Escrituras en memoria
# -------------------------

    sw      x6,  0(x2)
    sw      x7,  4(x2)

    sh      x8,  8(x2)
    sb      x9, 12(x2)

# -------------------------
# Lecturas de memoria
# -------------------------

    lw      x25, 0(x2)
    lw      x26, 4(x2)

    lh      x27, 8(x2)
    lhu     x28, 8(x2)

    lb      x29, 12(x2)
    lbu     x30, 12(x2)

# -------------------------
# Branches
# -------------------------

    beq     x25, x6, BEQ_OK
    addi    x31, x0, 111

BEQ_OK:

    bne     x25, x7, BNE_OK
    addi    x31, x31, 1

BNE_OK:

    blt     x5, x4, BLT_OK
    addi    x31, x31, 2

BLT_OK:

    bge     x4, x5, BGE_OK
    addi    x31, x31, 4

BGE_OK:

    bltu    x5, x4, BLTU_OK
    addi    x31, x31, 8

BLTU_OK:

    bgeu    x4, x5, BGEU_OK
    addi    x31, x31, 16

BGEU_OK:

# -------------------------
# JAL + JALR
# -------------------------

    jal     x10, FUNCION

# Cuando volvemos desde FUNCION
# debemos caer aquí.

FIN:
    beq     x0, x0, FIN

# -------------------------
# Subrutina
# -------------------------

FUNCION:

    addi    x11, x11, 123

    # vuelve a la dirección guardada
    # por el JAL anterior

    jalr    x0, 0(x10)
