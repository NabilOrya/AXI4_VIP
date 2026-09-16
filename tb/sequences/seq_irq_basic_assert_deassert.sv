// Sequence #43: seq_irq_basic_assert_deassert
// Features: F19, F22 (Interrupt Basic Assertion & Deassertion)
// Objective: Enables interrupts in CTRL and INT_EN, triggers an error event, and verifies IRQ line behavior.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_basic_assert_deassert extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_basic_assert_deassert)

  function new(string name = "seq_irq_basic_assert_deassert");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_IRQ_BASIC", "Executing Sequence #43: Basic IRQ Assertion/Deassertion", UVM_LOW)

    // Step 1: Enable irq_en in CTRL (CTRL[0] = 1 -> 0x1)
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000001;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    // Step 2: Enable error interrupt mask in INT_EN (INT_EN[2] = 1 -> 0x4)
    wr_seq = axi4_write_base_seq::type_id::create("wr_inten");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h1008;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000004;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);
    check_irq(1'b0, "before error event (empty flag not masked)");

    // Step 3: Trigger error event by attempting write to RO STATUS register
    wr_seq = axi4_write_base_seq::type_id::create("trig_err");
    wr_seq.seq_id        = 4'h0;
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
    check_irq(1'b1, "after error event");

    `uvm_info("SEQ_IRQ_BASIC", "Sequence #43 completed", UVM_LOW)
  endtask

endclass
