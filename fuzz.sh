#!/bin/bash
# Uso: ./fuzz.sh [num_programas] [semilla_inicial] [instrucciones]
N=${1:-50}; S=${2:-1}; LEN=${3:-60}
mkdir -p sim fuzz
malos=0
for ((s=S; s<S+N; s++)); do
  python3 tools/gen_random.py $s $LEN > fuzz/r$s.s
  java -jar tools/rars.jar nc mc CompactTextAtZero a dump .text HexText fuzz/r$s.hex fuzz/r$s.s \
      > sim/fuzz_rars.log 2>&1 || { echo "RARS ERROR semilla $s"; head -3 sim/fuzz_rars.log; malos=$((malos+1)); continue; }

  if [ "$(wc -l < fuzz/r$s.hex)" -gt 64 ]; then
    echo "semilla $s: >64 palabras, descartada"
    continue
  fi

  res=$(./compara.sh 400 fuzz/r$s.hex | head -1)
  case "$res" in
    ok*) ;;
    *) echo "semilla $s: $res"; malos=$((malos+1));;
  esac
done
echo "Programas: $N  Con problemas: $malos"
exit $malos