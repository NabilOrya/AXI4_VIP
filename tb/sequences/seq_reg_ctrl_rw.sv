// Sequence #4: seq_reg_ctrl_rw
// Features: F19, F20, F21 (CTRL Register R/W Check)
// Objective: Performs read/write operations to CTRL register (0x1000) for irq_en, fifo_en, and delay_en bits.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_ctrl_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_ctrl_rw)

  function new(string name = "seq_reg_ctrl_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_CTRL_RW", "Executing Sequence #4: CTRL Register R/W Check", UVM_LOW)

    // Write to CTRL (Enable irq_en, fifo_en, delay_en -> 3'b111 = 0x7)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id       = 4'h0;
    wr_seq.seq_addr     = 16'h1000; // A_CTRL
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00; // FIXED
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000007; // Enable all control bits
    wr_seq.check_resp  = 1;
    wr_seq.expect_resp = 2'b00;
    start_write(wr_seq);

    // Read back CTRL register
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h0;
    rd_seq.seq_addr = 16'h1000;
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    rd_seq.check_data  = 1;
    rd_seq.expect_data = 32'h00000007;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_CTRL_RW", "Sequence #4 completed", UVM_LOW)
  endtask

endclass
