#!/usr/bin/env bash
# Run one or more UVM tests under Cadence xrun; one log file per test.
# Usage (from sim/):
#   ./run_tests.sh                         # all tests below
#   ./run_tests.sh test_directed_regs      # one test
#   ./run_tests.sh test_fifo test_irq      # several tests

set -u

LOGDIR="logs"
mkdir -p "${LOGDIR}"

XRUN_BASE=(
  xrun -64bit -uvm -sv -access +rwc -timescale 1ns/1ps
  -f filelist.f
  -top top_example
  +UVM_VERBOSITY=UVM_MEDIUM
)

ALL_TESTS=(
  axi4_base_test
  test_reset
  test_directed_regs
  test_directed_burst_basic
  test_negative_burst
  test_addr_decode
  test_fifo
  test_irq
  test_outstanding_stress
  test_concurrent_rw
  test_backpressure
  test_random_regression
)

if [[ $# -gt 0 ]]; then
  TESTS=("$@")
else
  TESTS=("${ALL_TESTS[@]}")
fi

pass=0
fail=0
declare -a results

for t in "${TESTS[@]}"; do
  logfile="${LOGDIR}/${t}.log"
  echo "============================================================"
  echo "Running ${t}  ->  ${logfile}"
  echo "============================================================"

  # -l : Cadence writes the full tool/sim transcript to this file
  if "${XRUN_BASE[@]}" +UVM_TESTNAME="${t}" -l "${logfile}"; then
    xrun_rc=0
  else
    xrun_rc=$?
  fi

  if grep -q "\*\*\* ${t} PASSED \*\*\*" "${logfile}" 2>/dev/null; then
    echo "[PASS] ${t}"
    results+=("PASS  ${t}")
    pass=$((pass + 1))
  else
    echo "[FAIL] ${t}  (xrun_rc=${xrun_rc})  see ${logfile}"
    results+=("FAIL  ${t}")
    fail=$((fail + 1))
  fi
  echo
done

echo "============================================================"
echo "Summary: ${pass} passed, ${fail} failed"
echo "Logs in: ${LOGDIR}/"
for r in "${results[@]}"; do
  echo "  ${r}"
done
echo "============================================================"

[[ ${fail} -eq 0 ]]
