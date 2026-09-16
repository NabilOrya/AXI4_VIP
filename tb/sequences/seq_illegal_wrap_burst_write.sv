// Sequence #14: seq_illegal_wrap_burst_write
// Feature: F10 (WRAP Burst Rejection - Write)
// Objective: Drives a WRAP burst write (AWBURST=2'b10) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_wrap_burst_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_illegal_wrap_burst_write)

  function new(string name = "seq_illegal_wrap_burst_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_ILLEGAL_WRAP_WRITE", "Executing Sequence #14: Illegal WRAP Write Burst", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h1;
    wr_seq.seq_addr = 16'h0010;
    wr_seq.seq_len  = 8'h03; // 4 beats
    wr_seq.seq_size = 3'b010; // 4 bytes
    wr_seq.seq_burst= 2'b10; // WRAP burst (Illegal for DUT)
    wr_seq.allow_illegal = 1;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b10;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_WRAP_WRITE", "Sequence #14 completed", UVM_LOW)
  endtask

endclass
