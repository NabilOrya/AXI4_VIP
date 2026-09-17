// Sequence #46: seq_irq_w1c_clear
// Feature: F23 (INT_STATUS W1C - ones clear, zeros no-op)
// Objective: Prove write-0 leaves status/IRQ unchanged; write-1 clears error and drops IRQ.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_w1c_clear extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_w1c_clear)

  function new(string name = "seq_irq_w1c_clear");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_IRQ_W1C_CLEAR", "Executing Sequence #46: IRQ W1C Clear Test", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id        = 4'h3;
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

    wr_seq = axi4_write_base_seq::type_id::create("wr_inten");
    wr_seq.seq_id        = 4'h3;
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

    wr_seq = axi4_write_base_seq::type_id::create("trig_err");
    wr_seq.seq_id        = 4'h3;
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
    check_irq(1'b1, "IRQ asserted after error");

    // F23: writing 0 must not clear - IRQ stays asserted
    wr_seq = axi4_write_base_seq::type_id::create("w1c_zero");
    wr_seq.seq_id        = 4'h3;
    wr_seq.seq_addr      = 16'h100C;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000000;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);
    check_irq(1'b1, "after INT_STATUS write-0 (must not clear)");

    rd_seq = axi4_read_base_seq::type_id::create("rd_stat");
    rd_seq.seq_id      = 4'h3;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h4) == 0)
      `uvm_error("SEQ_IRQ_W1C_CLEAR",
        $sformatf("INT_STATUS[2] cleared by write-0: got=0x%0h", rd_seq.last_rdata))

    // Clear error bit with write-1
    wr_seq = axi4_write_base_seq::type_id::create("clear_w1c");
    wr_seq.seq_id        = 4'h3;
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
    check_irq(1'b0, "IRQ cleared via W1C");

    `uvm_info("SEQ_IRQ_W1C_CLEAR", "Sequence #46 completed", UVM_LOW)
  endtask

endclass
