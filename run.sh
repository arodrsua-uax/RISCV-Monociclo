#!/bin/bash
# Uso: ./run.sh prog/suma.s [ciclos]
src=$1; cyc=${2:-200}
base=$(basename "$src" .s)

java -jar tools/rars.jar nc mc CompactTextAtZero a dump .text HexText "mem/$base.hex" "$src" || exit 1
iverilog -g2012 -o sim/run_prog.vvp rtl/*.sv tools/run_prog.sv 2>&1 | grep -v sorry
vvp sim/run_prog.vvp "+prog=mem/$base.hex" "+cycles=$cyc" | grep -v "WARNING\|finish"
