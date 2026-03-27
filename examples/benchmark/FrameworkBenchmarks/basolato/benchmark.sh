#!/usr/bin/env bash

set -euo pipefail

BENCHMARK_DIR="/application/examples/benchmark/FrameworkBenchmarks/basolato"
PORT="${BENCH_PORT:-8080}"
WRK_DURATION="${BENCH_DURATION:-10}"
WRK_THREADS="${BENCH_THREADS:-4}"
WRK_CONNECTIONS_LIST="${BENCH_CONNECTIONS_LIST:-${BENCH_CONNECTIONS:-1500,1800,2000}}"
WRK_QUERY_COUNT="${BENCH_QUERY_COUNT:-500}"
OUTPUT_FILE="${BENCH_OUTPUT_FILE:-/application/examples/benchmark/FrameworkBenchmarks/basolato/benchmark_results}"
CACHE_DIR="${BENCH_CACHE_DIR:-/tmp/basolato_benchmark_cache}"
WRK_LATENCY_SCRIPT=""
SERVER_PID=""
SERVER_LOG=""
START_SERVER_BACKUP=""
START_SERVER_BACKUP_CREATED=0
RUN_ID=0

cd "$BENCHMARK_DIR"

backup_start_server() {
  if [ -f "./startServer.sh" ] && [ "$START_SERVER_BACKUP_CREATED" -eq 0 ]; then
    START_SERVER_BACKUP="$(mktemp /tmp/basolato_startServer_backup_XXXXXX.sh)"
    cp "./startServer.sh" "$START_SERVER_BACKUP"
    START_SERVER_BACKUP_CREATED=1
  fi
}

restore_start_server() {
  if [ "$START_SERVER_BACKUP_CREATED" -eq 1 ] && [ -n "$START_SERVER_BACKUP" ] && [ -f "$START_SERVER_BACKUP" ]; then
    mv -f "$START_SERVER_BACKUP" "./startServer.sh"
    START_SERVER_BACKUP_CREATED=0
    START_SERVER_BACKUP=""
  fi
}

cleanup() {
  if [ -n "${SERVER_PID:-}" ]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  if [ -n "${WRK_LATENCY_SCRIPT:-}" ] && [ -f "$WRK_LATENCY_SCRIPT" ]; then
    rm -f "$WRK_LATENCY_SCRIPT"
  fi
  if [ -n "${SERVER_LOG:-}" ] && [ -f "$SERVER_LOG" ]; then
    rm -f "$SERVER_LOG"
  fi
  rm -f main
  restore_start_server
}
trap cleanup EXIT

parse_connections() {
  local raw_csv="$1"
  IFS=',' read -r -a raw_values <<< "$raw_csv"
  CONNECTION_STEPS=()
  for value in "${raw_values[@]}"; do
    value="${value//[[:space:]]/}"
    if [ -z "$value" ]; then
      continue
    fi
    if [[ ! "$value" =~ ^[0-9]+$ ]] || [ "$value" -le 0 ]; then
      echo "ERROR: Invalid connection value: $value"
      exit 1
    fi
    CONNECTION_STEPS+=("$value")
  done

  if [ "${#CONNECTION_STEPS[@]}" -eq 0 ]; then
    echo "ERROR: No valid connection values found in BENCH_CONNECTIONS_LIST"
    exit 1
  fi
}

validate_query_count() {
  if [[ ! "$WRK_QUERY_COUNT" =~ ^[0-9]+$ ]] || [ "$WRK_QUERY_COUNT" -le 0 ]; then
    echo "ERROR: Invalid BENCH_QUERY_COUNT value: $WRK_QUERY_COUNT"
    exit 1
  fi
}

create_wrk_latency_script() {
  WRK_LATENCY_SCRIPT="$(mktemp /tmp/basolato_wrk_latency_XXXXXX.lua)"
  cat > "$WRK_LATENCY_SCRIPT" <<'EOF'
done = function(summary, latency, requests)
  io.write(string.format("Latency Percentile p95: %.2fms\n", latency:percentile(95.0) / 1000))
  io.write(string.format("Latency Percentile p99: %.2fms\n", latency:percentile(99.0) / 1000))
end
EOF
}

to_na_if_empty() {
  local value="$1"
  if [ -z "$value" ]; then
    echo "NA"
  else
    echo "$value"
  fi
}

wait_for_server() {
  local url="http://127.0.0.1:$PORT"
  for _ in {1..60}; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
  done
  return 1
}

write_header() {
  {
    echo "========================================"
    echo "Basolato FrameworkBenchmarks Results"
    echo "Date: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    echo "========================================"
    echo ""
    echo "Configuration:"
    echo "  Port: $PORT"
    echo "  Duration: ${WRK_DURATION}s"
    echo "  Connections: ${CONNECTION_STEPS[*]}"
    echo "  Threads: $WRK_THREADS"
    echo "  Query Count: $WRK_QUERY_COUNT"
    echo "  Endpoints: /plaintext /json /db /queries /fortunes /updates"
    echo ""
    echo -e "run_id\tendpoint\tconnections\trepeat\tstatus\tquery_count\trequests_per_sec\ttransfer_per_sec\tlatency_avg\tlatency_stdev\tlatency_max\tlatency_p95\tlatency_p99\ttimeout\tconnect_err\tread_err\twrite_err\ttotal_requests\tduration_sec"
  } > "$OUTPUT_FILE"
}

build_binary() {
  local output="$1"

  echo "========================================"
  echo "Building: basolato"
  echo "========================================"
  echo "Running: ducere build -o:speed -w:8 -a $output"

  backup_start_server
  mkdir -p "$CACHE_DIR"
  XDG_CACHE_HOME="$CACHE_DIR" ducere build -o:speed -w:8 -a "$output"

  if [ ! -f "$output" ]; then
    echo "ERROR: Build failed for basolato"
    exit 1
  fi
}

start_server() {
  SERVER_LOG="$(mktemp /tmp/basolato_framework_benchmark_XXXXXX.log)"
  ./main >"$SERVER_LOG" 2>&1 &
  SERVER_PID=$!
}

run_endpoint_benchmark() {
  local endpoint_name="$1"
  local endpoint_path="$2"
  local query_count="$3"
  local connections=""

  for connections in "${CONNECTION_STEPS[@]}"; do
    local url="http://127.0.0.1:$PORT$endpoint_path"
    local wrk_cmd="wrk --latency -t$WRK_THREADS -c$connections -d${WRK_DURATION}s -s $WRK_LATENCY_SCRIPT $url"
    local wrk_output=""
    local status="ok"

    {
      echo ""
      echo "========================================"
      echo "Benchmark: $endpoint_name"
      echo "Date: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
      echo "Connections: $connections"
      echo "Command: $wrk_cmd"
      echo "========================================"
      echo ""
    } >> "$OUTPUT_FILE"

    if ! wrk_output=$(wrk --latency -t"$WRK_THREADS" -c"$connections" -d"${WRK_DURATION}s" -s "$WRK_LATENCY_SCRIPT" "$url" 2>&1); then
      status="failed"
    fi

    printf "%s\n" "$wrk_output" >> "$OUTPUT_FILE"

    local requests_per_sec transfer_per_sec latency_avg latency_stdev latency_max latency_p95 latency_p99
    local timeout connect_err read_err write_err total_requests duration_sec
    requests_per_sec="$(printf '%s\n' "$wrk_output" | awk '/^Requests\/sec:/ {print $2; exit}' || true)"
    transfer_per_sec="$(printf '%s\n' "$wrk_output" | awk '/^Transfer\/sec:/ {print $2; exit}' || true)"
    latency_avg="$(printf '%s\n' "$wrk_output" | awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+/ {print $2; exit}' || true)"
    latency_stdev="$(printf '%s\n' "$wrk_output" | awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+/ {print $3; exit}' || true)"
    latency_max="$(printf '%s\n' "$wrk_output" | awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+/ {print $4; exit}' || true)"
    latency_p95="$(printf '%s\n' "$wrk_output" | awk -F': ' '/^Latency Percentile p95:/ {print $2; exit}' || true)"
    latency_p99="$(printf '%s\n' "$wrk_output" | awk -F': ' '/^Latency Percentile p99:/ {print $2; exit}' || true)"
    if [ -z "$latency_p95" ]; then
      latency_p95="$(printf '%s\n' "$wrk_output" | awk '/^[[:space:]]*95%/ {print $2; exit}' || true)"
    fi
    if [ -z "$latency_p99" ]; then
      latency_p99="$(printf '%s\n' "$wrk_output" | awk '/^[[:space:]]*99%/ {print $2; exit}' || true)"
    fi
    connect_err="0"
    read_err="0"
    write_err="0"
    timeout="0"
    total_requests=""
    duration_sec=""
    socket_errors=$(printf '%s\n' "$wrk_output" | sed -n 's/^[[:space:]]*Socket errors: connect \([0-9]\+\), read \([0-9]\+\), write \([0-9]\+\), timeout \([0-9]\+\).*/\1 \2 \3 \4/p' | head -n1)
    if [ -n "$socket_errors" ]; then
      read -r connect_err read_err write_err timeout <<< "$socket_errors"
    fi
    requests_line=$(printf '%s\n' "$wrk_output" | sed -n 's/^[[:space:]]*\([0-9]\+\) requests in \([0-9.]\+s\),.*/\1 \2/p' | head -n1)
    if [ -n "$requests_line" ]; then
      read -r total_requests duration_sec <<< "$requests_line"
    fi

    {
      echo ""
      echo "Parsed latency percentiles: p95=$(to_na_if_empty "$latency_p95"), p99=$(to_na_if_empty "$latency_p99")"
    } >> "$OUTPUT_FILE"

    RUN_ID=$((RUN_ID + 1))
    {
      echo -e "${RUN_ID}\t${endpoint_name}\t${connections}\t1\t${status}\t${query_count}\t$(to_na_if_empty "$requests_per_sec")\t$(to_na_if_empty "$transfer_per_sec")\t$(to_na_if_empty "$latency_avg")\t$(to_na_if_empty "$latency_stdev")\t$(to_na_if_empty "$latency_max")\t$(to_na_if_empty "$latency_p95")\t$(to_na_if_empty "$latency_p99")\t${timeout}\t${connect_err}\t${read_err}\t${write_err}\t$(to_na_if_empty "$total_requests")\t$(to_na_if_empty "$duration_sec")"
    } >> "$OUTPUT_FILE"
  done
}

parse_connections "$WRK_CONNECTIONS_LIST"
validate_query_count
create_wrk_latency_script
write_header
build_binary "main"
start_server

if ! wait_for_server; then
  echo "ERROR: Server did not become ready" | tee -a "$OUTPUT_FILE" >/dev/null
  if [ -f "$SERVER_LOG" ]; then
    cat "$SERVER_LOG" >> "$OUTPUT_FILE"
  fi
  exit 1
fi

if command -v wrk >/dev/null 2>&1; then
  :
else
  echo "ERROR: wrk command not found" | tee -a "$OUTPUT_FILE" >/dev/null
  exit 1
fi

run_endpoint_benchmark "plaintext" "/plaintext" "NA"
run_endpoint_benchmark "json" "/json" "NA"
run_endpoint_benchmark "db" "/db" "NA"
run_endpoint_benchmark "queries" "/queries?queries=${WRK_QUERY_COUNT}" "$WRK_QUERY_COUNT"
run_endpoint_benchmark "fortunes" "/fortunes" "NA"
run_endpoint_benchmark "updates" "/updates?queries=${WRK_QUERY_COUNT}" "$WRK_QUERY_COUNT"

{
  echo ""
  echo "========================================"
  echo "All Benchmarks Completed"
  echo "Date: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  echo "========================================"
} >> "$OUTPUT_FILE"

echo "========================================"
echo "All Benchmarks Completed"
echo "Date: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
echo "========================================"

echo "Completed: $OUTPUT_FILE"
