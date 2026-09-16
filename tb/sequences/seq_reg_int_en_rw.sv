// Sequence #6: seq_reg_int_en_rw
// Feature: F22 (INT_EN Masking Register R/W)
// Objective: Exercises read/write access to INT_EN register (0x1008) to configure interrupt masks.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_int_en_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_int_en_rw)

  function new(string name = "seq_reg_int_en_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_INT_EN_RW", "Executing Sequence #6: INT_EN R/W Check", UVM_LOW)

    // Write INT_EN (Enable bits [2:0] -> 3'b111)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id       = 4'h2;
    wr_seq.seq_addr     = 16'h1008; // A_INT_EN
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000007;
    wr_seq.check_resp  = 1;
    wr_seq.expect_resp = 2'b00;
    start_write(wr_seq);

    // Read back INT_EN
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h2;
    rd_seq.seq_addr = 16'h1008;
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_INT_EN_RW", "Sequence #6 completed", UVM_LOW)
  endtask

endclass
