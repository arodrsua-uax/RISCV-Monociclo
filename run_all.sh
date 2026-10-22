#!/bin/bash
# Regresion completa: monociclo, pipeline por pasos y comparacion entre ambos.
cd "$(dirname "$0")" || exit 1
mkdir -p sim
fallos=0

# Programas que se comparan monociclo vs pipeline (sin nop entre dependencias)
PROGRAMAS="mem/suma.hex mem/test_r.hex mem/test_r2.hex mem/test_lw.hex \
           mem/test_br.hex mem/test_jalr.hex mem/test_byte_ref.hex \
           mem/test_u.hex mem/test_lui.hex mem/test_auipc.hex mem/pipe7.hex"

echo "=== 1. Monociclo (run_tests.sh) ==="
./run_tests.sh | tail -3
[ ${PIPESTATUS[0]} -eq 0 ] || fallos=$((fallos+1))

echo
echo "=== 2. Pipeline (pipe/tb_pipe*.sv) ==="
PIPE_SRC="rtl/*.sv pipe/floprc.sv pipe/floprec.sv pipe/forwardunit.sv pipe/sysdec.sv pipe/csrfile.sv pipe/riscv_pipe.sv"
for tb in pipe/tb_pipe*.sv; do
  name=$(basename "$tb" .sv)
  if ! iverilog -g2012 -o "sim/$name.vvp" $PIPE_SRC "$tb" 2> "sim/$name.err"; then
    echo "COMPILA MAL  $name"; fallos=$((fallos+1)); continue
  fi
  out=$(vvp "sim/$name.vvp" 2>&1)
  if echo "$out" | grep -q "FALLO"; then
    echo "FAIL         $name"; fallos=$((fallos+1))
  elif echo "$out" | grep -q "todos los tests pasan"; then
    echo "ok           $name"
  else
    echo "SIN VEREDICTO $name"; fallos=$((fallos+1))
  fi
done

echo
echo "=== 3. Monociclo vs pipeline (compara.sh) ==="
./compara.sh $PROGRAMAS | tail -4
[ ${PIPESTATUS[0]} -eq 0 ] || fallos=$((fallos+1))

echo
echo "========================================"
if [ $fallos -eq 0 ]; then echo "TODO EN VERDE"; else echo "FALLOS EN $fallos APARTADO(S)"; fi
exit $fallos