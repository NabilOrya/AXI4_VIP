// Sequence #37: seq_addr_reg_gap_decerr
// Feature: F15 (Address Decode — Register Region Gap DECERR Rejection)
// Objective: Issues read/write requests to unmapped address offsets in the 0x1000–0x1FFF region (e.g. 0x1020) to verify DECERR.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_reg_gap_decerr extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_reg_gap_decerr)

  function new(string name = "seq_addr_reg_gap_decerr");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] gap_addrs[2] = '{16'h1020, 16'h1080};

    `uvm_info("SEQ_ADDR_REG_GAP_DECERR", "Executing Sequence #37: Register Window Gap DECERR Sweep", UVM_LOW)

    foreach (gap_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id   = 4'h4;
      wr_seq.seq_addr = gap_addrs[i];
      wr_seq.seq_len  = 8'h00;
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b00;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b11;
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id   = 4'h4;
      rd_seq.seq_addr = gap_addrs[i];
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b00;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b11;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_REG_GAP_DECERR", "Sequence #37 completed", UVM_LOW)
  endtask

endclass
