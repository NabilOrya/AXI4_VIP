// Sequence #10: seq_reg_delay_cfg_rw
// Feature: F29 (DELAY_CFG Register R/W & Split Delay Control)
// Objective: Writes and reads DELAY_CFG (0x1018) to verify write-side [3:0] and read-side [7:4] limits.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_delay_cfg_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_delay_cfg_rw)

  function new(string name = "seq_reg_delay_cfg_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_DELAY_CFG_RW", "Executing Sequence #10: DELAY_CFG R/W Check", UVM_LOW)

    // Write DELAY_CFG (Set write max delay=4 [3:0], read max delay=8 [7:4] -> 0x84)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id       = 4'h6;
    wr_seq.seq_addr     = 16'h1018; // A_DELAY_CFG
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000084;
    wr_seq.check_resp  = 1;
    wr_seq.expect_resp = 2'b00;
    start_write(wr_seq);

    // Read back DELAY_CFG
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h6;
    rd_seq.seq_addr = 16'h1018;
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    rd_seq.check_data  = 1;
    rd_seq.expect_data = 32'h00000084;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_DELAY_CFG_RW", "Sequence #10 completed", UVM_LOW)
  endtask

endclass
