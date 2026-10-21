#!/bin/bash
# Uso: ./compara.sh [ciclos] mem/a.hex mem/b.hex ...
cyc=400
if [[ $1 =~ ^[0-9]+$ ]]; then cyc=$1; shift; fi
[ $# -eq 0 ] && { echo "Uso: $0 [ciclos] fichero.hex ..."; exit 2; }
mkdir -p sim

build() {   # $1 = modulo superior, $2 = salida, resto = fuentes
  local top=$1 out=$2; shift 2
  iverilog -g2012 -s "$top" -o "$out" "$@" 2> sim/cmp.err || { grep -v sorry sim/cmp.err; exit 1; }
}
build run_prog sim/cmp_mono.vvp rtl/*.sv tools/run_prog.sv
build run_pipe sim/cmp_pipe.vvp rtl/*.sv pipe/floprc.sv pipe/floprec.sv \
      pipe/forwardunit.sv pipe/riscv_pipe.sv tools/run_pipe.sv

malos=0
for hex in "$@"; do
  vvp sim/cmp_mono.vvp "+prog=$hex" "+cycles=$cyc" 2>&1 | grep '^[RM] ' > sim/cmp_mono.trace
  vvp sim/cmp_pipe.vvp "+prog=$hex" "+cycles=$cyc" 2>&1 | grep '^[RM] ' > sim/cmp_pipe.trace

  if [ ! -s sim/cmp_mono.trace ]; then
    echo "SIN TRAZA  $hex"; malos=$((malos+1)); continue
  fi

  ok=1
  for k in R M; do
    diff <(grep "^$k " sim/cmp_mono.trace) <(grep "^$k " sim/cmp_pipe.trace) > "sim/cmp_$k.diff" || ok=0
  done

  nr=$(grep -c '^R ' sim/cmp_mono.trace); nm=$(grep -c '^M ' sim/cmp_mono.trace)
  if [ $ok -eq 1 ]; then
    echo "ok         $hex  ($nr registros, $nm memoria)"
  else
    echo "DIFIERE    $hex"
    for k in R M; do [ -s "sim/cmp_$k.diff" ] && { echo "  --- $k (< monociclo, > pipeline)"; head -6 "sim/cmp_$k.diff"; }; done
    malos=$((malos+1))
  fi
done
echo "----------------------------------------"
echo "DIFIEREN: $malos"
exit $malos