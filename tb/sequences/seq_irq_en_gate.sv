// Sequence #45: seq_irq_en_gate
// Feature: F19 (CTRL irq_en Global Gate Verification)
// Objective: Disables irq_en in CTRL (bit0=0) while active interrupt flags are set to verify IRQ stays 0.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_en_gate extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_en_gate)

  function new(string name = "seq_irq_en_gate");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_IRQ_EN_GATE", "Executing Sequence #45: Global IRQ Gate Check", UVM_LOW)

    // Step 1: Enable INT_EN (INT_EN = 0x7)
    wr_seq = axi4_write_base_seq::type_id::create("wr_inten");
    wr_seq.seq_id        = 4'h2;
    wr_seq.seq_addr      = 16'h1008;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000007;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    // Step 2: Disable irq_en in CTRL (CTRL = 0x0)
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id        = 4'h2;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000000;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    // Step 3: Trigger error event to set INT_STATUS[2]
    wr_seq = axi4_write_base_seq::type_id::create("trig_err");
    wr_seq.seq_id        = 4'h2;
    wr_seq.seq_addr      = 16'h1004;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'hFFFFFFFF;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_SLVERR;
    start_write(wr_seq);

    // irq_en=0 must force IRQ low regardless of INT_EN/INT_STATUS
    check_irq(1'b0, "irq_en gated off");

    `uvm_info("SEQ_IRQ_EN_GATE", "Sequence #45 completed", UVM_LOW)
  endtask

endclass
