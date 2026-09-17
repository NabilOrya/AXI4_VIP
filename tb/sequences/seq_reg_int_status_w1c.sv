// Sequence #7: seq_reg_int_status_w1c
// Features: F23, F25
// Objective: Force error bit, W1C clear it; empty may re-assert (F24). Ref/SB check RDATA.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_int_status_w1c extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_int_status_w1c)

  function new(string name = "seq_reg_int_status_w1c");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_INT_STATUS_W1C", "Executing Sequence #7: INT_STATUS W1C Check", UVM_LOW)

    // Force INT_STATUS[2] via RO STATUS write
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

    rd_seq = axi4_read_base_seq::type_id::create("rd_before");
    rd_seq.seq_id      = 4'h3;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h4) == 0)
      `uvm_error("SEQ_REG_INT_STATUS_W1C",
        $sformatf("INT_STATUS[2] not set after error: got=0x%0h", rd_seq.last_rdata))

    wr_seq = axi4_write_base_seq::type_id::create("w1c");
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

    rd_seq = axi4_read_base_seq::type_id::create("rd_after");
    rd_seq.seq_id      = 4'h3;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h4) != 0)
      `uvm_error("SEQ_REG_INT_STATUS_W1C",
        $sformatf("INT_STATUS[2] still set after W1C: got=0x%0h", rd_seq.last_rdata))

    `uvm_info("SEQ_REG_INT_STATUS_W1C", "Sequence #7 completed", UVM_LOW)
  endtask

endclass
