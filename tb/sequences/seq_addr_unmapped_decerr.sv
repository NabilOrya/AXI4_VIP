// Sequence #35: seq_addr_unmapped_decerr
// Feature: F17 (Address Decode — Unmapped Space DECERR Rejection)
// Objective: Issues read and write requests to unmapped address ranges to verify DECERR generation.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_unmapped_decerr extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_unmapped_decerr)

  function new(string name = "seq_addr_unmapped_decerr");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] unmapped_addrs[2] = '{16'h3000, 16'h8000};

    `uvm_info("SEQ_ADDR_UNMAPPED_DECERR", "Executing Sequence #35: Unmapped Space DECERR Sweep", UVM_LOW)

    foreach (unmapped_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id   = 4'h2;
      wr_seq.seq_addr = unmapped_addrs[i];
      wr_seq.seq_len  = 8'h00;
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b01;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b11;
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id   = 4'h2;
      rd_seq.seq_addr = unmapped_addrs[i];
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b01;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b11;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_UNMAPPED_DECERR", "Sequence #35 completed", UVM_LOW)
  endtask

endclass
