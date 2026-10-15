#!/bin/bash
# Ejecuta todos los testbenches de tb/ y resume el resultado.
mkdir -p sim
pass=0; fail=0; fallidos=""

for tb in tb/tb_*.sv; do
  name=$(basename "$tb" .sv)
  # Compilar: errores reales (no los avisos "sorry")
  if ! iverilog -g2012 -o "sim/$name.vvp" rtl/*.sv "$tb" 2> "sim/$name.err"; then
    echo "COMPILA MAL  $name"
    fail=$((fail+1)); fallidos="$fallidos $name"
    continue
  fi
  out=$(vvp "sim/$name.vvp" 2>&1)
  if echo "$out" | grep -q "FALLO\|fallos" && ! echo "$out" | grep -q "todos los tests pasan"; then
    echo "FAIL         $name"
    fail=$((fail+1)); fallidos="$fallidos $name"
  elif echo "$out" | grep -q "FALLO"; then
    echo "FAIL         $name"
    fail=$((fail+1)); fallidos="$fallidos $name"
  elif echo "$out" | grep -q "pasan\|terminado"; then
    echo "ok           $name"
    pass=$((pass+1))
  else
    echo "SIN VEREDICTO $name"
    fail=$((fail+1)); fallidos="$fallidos $name"
  fi
done

echo "----------------------------------------"
echo "PASAN: $pass   FALLAN: $fail"
[ $fail -ne 0 ] && echo "Revisa:$fallidos"
exit $fail
