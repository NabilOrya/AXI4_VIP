`timescale 1ns/1ps

package axi4_env_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // Declare analysis-imp suffixes once for the whole package
  `uvm_analysis_imp_decl(_write)
  `uvm_analysis_imp_decl(_read)
  `uvm_analysis_imp_decl(_exp_write)
  `uvm_analysis_imp_decl(_exp_read)

  // Write Agent
  `include "agents/write_agent/axi4_write_txn.sv"
  `include "agents/write_agent/axi4_write_driver.sv"
  `include "agents/write_agent/axi4_write_monitor.sv"
  `include "agents/write_agent/axi4_write_sequencer.sv"
  `include "agents/write_agent/axi4_write_agent.sv"

  // Read Agent
  `include "agents/read_agent/axi4_read_txn.sv"
  `include "agents/read_agent/axi4_read_driver.sv"
  `include "agents/read_agent/axi4_read_monitor.sv"
  `include "agents/read_agent/axi4_read_sequencer.sv"
  `include "agents/read_agent/axi4_read_agent.sv"

  // Sequences
  `include "sequences/axi4_write_base_seq.sv"
  `include "sequences/axi4_read_base_seq.sv"
  `include "sequences/axi4_vseq_base.sv"

  // A. Reset & Sanity (1-3)
  `include "sequences/seq_reset_basic.sv"
  `include "sequences/seq_reset_readback_zero.sv"
  `include "sequences/seq_reset_midtxn.sv"

  // B. Directed Register Access (4-13)
  `include "sequences/seq_reg_ctrl_rw.sv"
  `include "sequences/seq_reg_status_ro_check.sv"
  `include "sequences/seq_reg_int_en_rw.sv"
  `include "sequences/seq_reg_int_status_w1c.sv"
  `include "sequences/seq_reg_fifo_data_access.sv"
  `include "sequences/seq_reg_fifo_status_ro_check.sv"
  `include "sequences/seq_reg_delay_cfg_rw.sv"
  `include "sequences/seq_reg_txn_count_ro_check.sv"
  `include "sequences/seq_reg_bit_bash_all.sv"
  `include "sequences/seq_reg_hw_reset_check.sv"

  // C. Negative — Burst Legality (14-23)
  `include "sequences/seq_illegal_wrap_burst_write.sv"
  `include "sequences/seq_illegal_wrap_burst_read.sv"
  `include "sequences/seq_illegal_reserved_burst_write.sv"
  `include "sequences/seq_illegal_reserved_burst_read.sv"
  `include "sequences/seq_illegal_len_gt15_write.sv"
  `include "sequences/seq_illegal_len_gt15_read.sv"
  `include "sequences/seq_illegal_size_gt2_write.sv"
  `include "sequences/seq_illegal_size_gt2_read.sv"
  `include "sequences/seq_illegal_4k_boundary_write.sv"
  `include "sequences/seq_illegal_4k_boundary_read.sv"

  // D. Positive — Legal Burst Variants (24-32)
  `include "sequences/seq_legal_fixed_burst_write.sv"
  `include "sequences/seq_legal_fixed_burst_read.sv"
  `include "sequences/seq_legal_incr_burst_write.sv"
  `include "sequences/seq_legal_incr_burst_read.sv"
  `include "sequences/seq_max_length_burst_write.sv"
  `include "sequences/seq_max_length_burst_read.sv"
  `include "sequences/seq_single_beat_write.sv"
  `include "sequences/seq_single_beat_read.sv"
  `include "sequences/seq_wstrb_sweep_write.sv"

  // E. Address Decode (33-37)
  `include "sequences/seq_addr_ram_region_rw.sv"
  `include "sequences/seq_addr_reg_region_rw.sv"
  `include "sequences/seq_addr_unmapped_decerr.sv"
  `include "sequences/seq_addr_error_window_slverr.sv"
  `include "sequences/seq_addr_reg_gap_decerr.sv"

  // F. FIFO Scenarios (38-42)
  `include "sequences/seq_fifo_push_pop_basic.sv"
  `include "sequences/seq_fifo_overflow_push_while_full.sv"
  `include "sequences/seq_fifo_underflow_pop_while_empty.sv"
  `include "sequences/seq_fifo_disable_clears_contents.sv"
  `include "sequences/seq_fifo_partial_strobe_reject.sv"

  // G. Interrupt Scenarios (43-47)
  `include "sequences/seq_irq_basic_assert_deassert.sv"
  `include "sequences/seq_irq_mask_sweep.sv"
  `include "sequences/seq_irq_en_gate.sv"
  `include "sequences/seq_irq_w1c_clear.sv"
  `include "sequences/seq_irq_level_set_fifo_flags.sv"

  // H. Outstanding / Backpressure / Ordering (48-50)
  `include "sequences/seq_outstanding_depth_stress.sv"
  `include "sequences/seq_backpressure_sweep.sv"
  `include "sequences/seq_concurrent_read_write.sv"

  // Env Components
  `include "env/axi4_ref_model.sv"
  `include "env/axi4_coverage.sv"
  `include "env/axi4_scoreboard.sv"
  `include "env/axi4_env.sv"

  // Tests (§4.10 + Phase-1 smoke)
  `include "tests/axi4_test_base.sv"
  `include "tests/axi4_base_test.sv"
  `include "tests/test_reset.sv"
  `include "tests/test_directed_regs.sv"
  `include "tests/test_directed_burst_basic.sv"
  `include "tests/test_negative_burst.sv"
  `include "tests/test_addr_decode.sv"
  `include "tests/test_fifo.sv"
  `include "tests/test_irq.sv"
  `include "tests/test_outstanding_stress.sv"
  `include "tests/test_concurrent_rw.sv"
  `include "tests/test_backpressure.sv"
  `include "tests/test_random_regression.sv"
endpackage
