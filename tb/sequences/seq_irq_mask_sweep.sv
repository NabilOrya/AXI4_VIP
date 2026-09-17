// Sequence #44: seq_irq_mask_sweep
// Feature: F22 (INT_EN Interrupt Masking Sweep)
// Objective: Clean post-reset INT_STATUS (empty only), then sweep INT_EN vs IRQ.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_mask_sweep extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_mask_sweep)

  function new(string name = "seq_irq_mask_sweep");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    // After pulse_reset: FIFO empty -> INT_STATUS[1]=1, error/full cleared.
    // irq_en=1: masks that enable empty (bit1) raise IRQ; others stay 0.
    bit [31:0] masks[5]   = '{32'h0, 32'h1, 32'h2, 32'h4, 32'h7};
    bit        exp_irq[5] = '{1'b0, 1'b0, 1'b1, 1'b0, 1'b1};

    `uvm_info("SEQ_IRQ_MASK_SWEEP", "Executing Sequence #44: IRQ Mask Sweep", UVM_LOW)

    resolve_handles();
    pulse_reset();

    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id        = 4'h1;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000001; // irq_en only
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    foreach (masks[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("mask_%0d", i));
      wr_seq.seq_id        = 4'h1;
      wr_seq.seq_addr      = 16'h1008;
      wr_seq.seq_len       = 8'h00;
      wr_seq.seq_size      = 3'b010;
      wr_seq.seq_burst     = 2'b00;
      wr_seq.override_data = 1;
      wr_seq.seq_data      = new[1];
      wr_seq.seq_data[0]   = masks[i];
      wr_seq.check_resp    = 1;
      wr_seq.expect_resp   = RESP_OKAY;
      start_write(wr_seq);
      check_irq(exp_irq[i], $sformatf("INT_EN=0x%0h", masks[i]));
    end

    `uvm_info("SEQ_IRQ_MASK_SWEEP", "Sequence #44 completed", UVM_LOW)
  endtask

endclass
