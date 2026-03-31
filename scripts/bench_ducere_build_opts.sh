#!/usr/bin/env bash
# fixブランチ: ducere build 相当の Nim フラグ比較用（手動実行）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/examples/example"
OUTDIR="${TMPDIR:-/tmp}/basolato_build_bench"
mkdir -p "$OUTDIR"
cd "$APP"
export SECRET_KEY="${SECRET_KEY:-$(grep '^SECRET_KEY=' .env | cut -d= -f2- | tr -d '"')}"

# buildImpl に揃えた共通フラグ（jsBuild 除く）
COMMON=(
  --threads:off
  -d:ssl
  -d:release
  --parallelBuild:0
  --panics:on
)

elapsed_sec() {
  local start end
  start="$(date +%s.%N)"
  "$@"
  end="$(date +%s.%N)"
  awk -v a="$start" -v b="$end" 'BEGIN{printf "%.3f", b-a}'
}

run_variant() {
  local name="$1"
  shift
  local out="$OUTDIR/$name"
  local i t sum=0
  rm -f "$out"
  for i in 1 2 3; do
    rm -f "$out"
    t="$(elapsed_sec nim c -f "${COMMON[@]}" "$@" --out:"$out" main.nim)"
    sum="$(awk -v a="$sum" -v b="$t" 'BEGIN{printf "%.6f", a+b}')"
  done
  rm -f "$out"
  nim c -f "${COMMON[@]}" "$@" --out:"$out" main.nim >/dev/null
  local bytes
  bytes="$(stat -c%s "$out" 2>/dev/null || stat -f%z "$out")"
  echo "$name	$(awk -v s="$sum" 'BEGIN{printf "%.3f", s/3}')	$bytes"
  rm -f "$out"
}

echo "# Nim $(nim --version | head -1)"
echo "# cwd $APP"
echo "# 各設定: nim c -f を3回、表示は wall 秒の平均。最後に1回ビルドしてバイナリサイズ取得"
echo "variant	avg_compile_sec_s	bytes"

# GC + 最適化軸
run_variant "mem_danger_lto" --mm:orc -d:useMalloc -d:danger --passC:"-flto" --passL:"-flto"
run_variant "speed_danger_lto" --mm:markAndSweep -d:useRealtimeGC -d:danger --passC:"-flto" --passL:"-flto"
run_variant "mem_danger_no_lto" --mm:orc -d:useMalloc -d:danger
run_variant "speed_danger_no_lto" --mm:markAndSweep -d:useRealtimeGC -d:danger
run_variant "mem_nodanger_lto" --mm:orc -d:useMalloc --passC:"-flto" --passL:"-flto"
run_variant "speed_nodanger_lto" --mm:markAndSweep -d:useRealtimeGC --passC:"-flto" --passL:"-flto"

# --threads:on は Basolato 標準サーバが GC-safety でコンパイル不能のため計測対象外
