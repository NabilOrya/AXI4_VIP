# AXI4 VIP — Project Progress Report

**Repository:** https://github.com/NabilOrya/AXI4_VIP  
**Project:** UVM Verification of AXI4 Full Burst Memory and FIFO Peripheral (`axi4_peripheral`)  
**Plan source:** `docs/AXI4_Verification_Plan.docx`  
**Report date:** 2026-09-17  
**Overall completion (vs full plan + submission):** **~60%**

---

## 1. One-line status

Phase-1 core pipe is **Cadence-proven** (`axi4_base_test` PASS on Xcelium 24.09). All 50 sequences and all §4.10 tests are coded. Phase-2 suite has not yet been run/closed on Cadence; drivers still block true outstanding/backpressure stress. Phase-3 RAL, full regression, and sign-off artifacts are not started.

---

## 2. What this project is

| Item | Detail |
|------|--------|
| DUT | `rtl/axi4_peripheral.sv` + `rtl/axi_fifo.sv` |
| Bus | AXI4-Full slave, 16-bit addr, 32-bit data, 4-bit ID, IRQ |
| Blocks | 4 KiB RAM, 8 registers, 16×32 FIFO, interrupt ctrl, delay/backpressure |
| Goal | Self-checking UVM VIP per verification plan (F1–F38, 50 sequences, coverage, SVA, RAL, regression) |
| Sim target | Cadence Xcelium (`xrun`) from `sim/` |

---

## 3. Overall progress vs verification plan

| Area (plan section) | Weight | Done | Status |
|---------------------|--------|------|--------|
| Verification plan / docs | 5% | 5% | Complete |
| DUT + IF + top + filelist | 5% | 5% | Complete |
| Agents (txn / seqr / driver / monitor) | 15% | 12% | Drivers Phase-1 sequential; monitors complete |
| Sequence library (50 seqs) | 15% | 11% | All files present; some scenarios incomplete |
| Reference model §4.5 | 12% | 9% | Core predict + shadow state done |
| Scoreboard §4.6 | 10% | 7% | In-order txn compare done; no cycle IRQ check |
| Functional coverage §4.7 | 8% | 4% | 10 covergroups built; partial sampling |
| SVA §4.9 | 5% | 2% | Partial (stability / no-X / reset) |
| Test list §4.10 | 10% | 8% | All 11 plan tests + smoke coded; only smoke Cadence-proven |
| RAL §4.8 (Phase 3) | 8% | 0% | Not started |
| Regression / reports / exit §4.11 | 7% | 1% | Smoke proven; no suite regression / closure reports |

**Estimated total: ~60%.**

### Phase view

| Phase | Plan intent | Status |
|-------|-------------|--------|
| **Phase 1** | Core pipe: agents, monitors, ref, SB; simple directed prove-out | **~95%** — Cadence smoke **PASSED** 2026-09-17 |
| **Phase 2** | Burst / addr / FIFO / IRQ / stress without RAL | **~50%** — sequences + §4.10 tests coded; Cadence suite not closed; stress gaps remain |
| **Phase 3** | RAL + `uvm_reg_*` reuse | **0%** |
| **Sign-off** | Clean regression, coverage goals, reports, Appendix A closed | **0%** |

---

## 4. What is done (usable now)

### Infrastructure
- `tb/axi4_if.sv` — full AXI + IRQ  
- `tb/top_example.sv` — clock/reset, DUT, SVA bind, `run_test`  
- `sim/filelist.f` — RTL + IF + SVA + package + top  
- `tb/axi4_env_pkg.sv` — package includes all TB sources  
- GitHub repo initialized and pushed  

### Agents
- Write/read **transactions**, **sequencers**, **agents**  
- **Drivers** — full AW/W/B and AR/R handshakes (sequential / always-ready)  
- **Monitors** — reconstruct bursts, BID/RID checks, analysis ports  

### Checking path (Phase 1)
- **`axi4_ref_model`** — shadow RAM / regs / FIFO; predicts BRESP/RRESP/RDATA; IRQ formula; illegal burst & decode; FIFO rules (underflow = OKAY per Appendix A / RTL)  
- **`axi4_scoreboard`** — monitor actual vs ref expected (ID, addr, resp, RDATA)  
- **Env wiring:** Monitor → Ref → SB (expected); Monitor → SB (actual); Monitor → Coverage  

### Sequences
- All **50 named sequences** from the plan exist under `tb/sequences/`  
- Base seqs with `allow_illegal`, `check_resp`, optional `check_data`  
- `axi4_vseq_base` for mixed R+W + `check_irq`  
- Illegal / addr-decode / many IRQ seqs have directed checks  

### Tests (§4.10) — coded
`test_reset`, `test_directed_regs`, `test_directed_burst_basic`, `test_negative_burst`, `test_addr_decode`, `test_fifo`, `test_irq`, `test_outstanding_stress`, `test_concurrent_rw`, `test_backpressure`, `test_random_regression` (+ smoke `axi4_base_test`). Select with `+UVM_TESTNAME=<name>`.

### Cadence proof (Phase 1 smoke) — **PASSED**
- Date: **2026-09-17**, tool: `xrun` 24.09-s008 (Xcelium)  
- Command: `+UVM_TESTNAME=axi4_base_test` from `sim/`  
- Result: compile/elab OK; `WR MATCH` / `RD MATCH` (CTRL `0x7`); `*** axi4_base_test PASSED ***` @ 175 ns; 0 UVM_ERROR / UVM_FATAL  
- Compile noise only: UTF-8 em-dash `NONPRT` warnings in `axi4_vseq_base.sv` / `test_random_regression.sv` (non-blocking); unused `+incdir+../rtl`  

### Coverage / SVA (partial)
- 10 covergroups in `axi4_coverage.sv`; SVA module bound in top  

---

## 5. What is not done / incomplete

### Drivers (plan §4.3)
- No pipelined AW ahead of W (blocks true F2/F3 outstanding stress)  
- No programmable BREADY/RREADY backpressure (F37)  

### Reference / scoreboard gaps
- Ref does not yet model QDEPTH READY stalls  
- Scoreboard does not continuously sample IRQ vs live prediction  
- No post-txn mirror-style register sweeps beyond txn compare  

### Sequences still weak
- `seq_reset_midtxn` — does not drive `ARESETn`  
- `seq_outstanding_depth_stress` — serial completes; cannot hit QDEPTH=4 stall with current driver  
- `seq_backpressure_sweep` — DUT delay only; no master-side ready throttle  
- Several seqs lack strong data/level golden checks (rely on SB + dedicated tests)  

### Cadence execution beyond smoke
- §4.10 tests are **coded** but **not yet proven/closed** on Cadence as a suite  

### RAL (§4.8) — missing
`axi4_reg_block`, `axi4_reg_adapter`, real `uvm_reg_bit_bash_seq` / `uvm_reg_hw_reset_seq` integration  

### SVA still missing vs plan
`a_wlast_count`, `a_rlast_count`, `a_resp_id_match`, `a_irq_formula`  

### Coverage sampling
`cg_ctrl`, `cg_irq`, `cg_fifo`, `cg_delay`, `cg_outstanding` not fully sampled yet  

### Sign-off / submission
- No Cadence suite regression logs / scripts  
- No functional/code coverage closure report  
- No final verification report / bug reports  
- Appendix A mentor decisions not formally closed  

---

## 6. Feature traceability snapshot (F1–F38)

| Band | Features | Stimulus | Independent checking (ref/SB) |
|------|----------|----------|-------------------------------|
| Reset / queues | F1–F3 | Partial / weak for F2–F3 | Not ready |
| Write/read protocol | F4–F9 | Mostly yes | Proven on smoke path; broader coverage via SB |
| Illegal burst | F10–F13 | Yes | Partial (directed + SB); Cadence suite TBD |
| Address decode | F14–F17 | Yes | Partial; Cadence suite TBD |
| Registers / IRQ | F18–F25 | Yes | CTRL path Cadence-proven; rest TBD |
| FIFO | F26–F28 | Yes | Partial; Cadence suite TBD |
| Delay / txn count | F29–F30 | Yes | Weak |
| Concurrent / order | F31–F33 | Partial | Weak |
| Mid-reset / precedence | F34–F35 | Weak / missing | Not ready |
| Backpressure / max stress | F36–F38 | Partial | Weak |

**Summary:** Almost all features have **named sequences** and **named tests**. Phase-1 smoke is Cadence-closed. Few features are **fully closed** by monitor→ref→SB + Cadence-proven dedicated tests.

---

## 7. How to run (Cadence PC)

```bash
git clone https://github.com/NabilOrya/AXI4_VIP.git
# or: git pull
cd AXI4_VIP/sim

xrun -64bit -uvm -sv -access +rwc -timescale 1ns/1ps \
  -f filelist.f \
  -top top_example \
  +UVM_TESTNAME=axi4_base_test \
  +UVM_VERBOSITY=UVM_MEDIUM
```

**Proven healthy result (2026-09-17):**
- UVM topology print  
- Driver / monitor activity on CTRL write+read  
- Scoreboard `WR MATCH` / `RD MATCH` (`RDATA=0x00000007`)  
- `*** axi4_base_test PASSED ***`  
- 0 UVM_ERROR / UVM_FATAL  

Other tests: same command with `+UVM_TESTNAME=<test_name>` (see §4).

---

## 8. Recommended next steps (priority order)

1. **Run Phase-2 Cadence suite** — `test_reset`, `test_directed_regs`, `test_directed_burst_basic`, `test_negative_burst`, `test_addr_decode`, `test_fifo`, `test_irq` (then stress tests)  
2. **Upgrade drivers** — outstanding AW/W + random ready (unlock F2/F3/F37)  
3. **Harden weak sequences** — mid-txn reset, outstanding stress, FIFO data checks  
4. **Finish coverage sampling + remaining SVA**  
5. **Phase 3 RAL**  
6. **Regression + coverage closure + final report**  
7. *(Optional)* Replace UTF-8 em-dashes in TB strings to clear `NONPRT` warnings  

---

## 9. Key paths (for a teammate opening the repo)

```
AXI4_VIP/
  docs/          Verification plan + project brief + this report
  rtl/           DUT
  sim/filelist.f xrun file list (run from sim/)
  tb/
    axi4_if.sv, axi4_sva.sv, axi4_env_pkg.sv, top_example.sv
    agents/      write + read VIP
    env/         ref_model, scoreboard, coverage, env
    sequences/   50 plan sequences + bases
    tests/       axi4_test_base, axi4_base_test (smoke), 11 §4.10 tests
```

---

## 10. Honest summary for a friend / future self

> We have a real UVM AXI4 VIP aligned to the verification plan: DUT, interface, two agents with working drivers/monitors, full sequence catalog, all §4.10 tests, a transaction-level reference model and comparing scoreboard, and partial coverage/SVA. **Phase-1 smoke passed on Cadence `xrun` (2026-09-17).** Roughly **40%** of the full project remains: Cadence Phase-2 suite closure, driver upgrades for outstanding/backpressure, coverage/SVA finish, RAL, regression, and sign-off. Next critical milestone: **run and close the §4.10 directed tests on Cadence**.

---

*Updated 2026-09-17 after Cadence Phase-1 smoke PASS. Update again when Phase-2 suite is Cadence-closed or Phase 3/RAL starts.*
