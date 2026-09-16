// Sequence #34: seq_addr_reg_region_rw
// Feature: F15 (Address Decode — Register Region 0x1000–0x101C)
// Objective: Sweeps defined register addresses to verify legal region decode returning OKAY.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_reg_region_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_reg_region_rw)

  function new(string name = "seq_addr_reg_region_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] reg_addrs[4] = '{16'h1000, 16'h1008, 16'h1010, 16'h1018}; // CTRL, INT_EN, FIFO_DATA, DELAY_CFG

    `uvm_info("SEQ_ADDR_REG_RW", "Executing Sequence #34: Register Region Address Decode Sweep", UVM_LOW)

    foreach (reg_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id   = 4'h1;
      wr_seq.seq_addr = reg_addrs[i];
      wr_seq.seq_len  = 8'h00;
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b00;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b00;
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id   = 4'h1;
      rd_seq.seq_addr = reg_addrs[i];
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b00;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b00;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_REG_RW", "Sequence #34 completed", UVM_LOW)
  endtask

endclass
