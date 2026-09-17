// Sequence #43: seq_irq_basic_assert_deassert
// Features: F19, F22, F23, F25
// Objective: Assert IRQ on error event, then deassert via INT_STATUS W1C.

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

    // CTRL.irq_en=1
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

    // INT_EN = error only (bit2) - empty flag must not raise IRQ
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

    // Trigger INT_STATUS[2] via RO STATUS write
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

    // Deassert: W1C clear error bit
    wr_seq = axi4_write_base_seq::type_id::create("w1c_err");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h100C;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000004;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);
    check_irq(1'b0, "after W1C deassert");

    `uvm_info("SEQ_IRQ_BASIC", "Sequence #43 completed", UVM_LOW)
  endtask

endclass
