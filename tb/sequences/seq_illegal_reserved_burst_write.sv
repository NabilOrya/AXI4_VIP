// Sequence #16: seq_illegal_reserved_burst_write
// Feature: F10 (Reserved Burst Rejection - Write)
// Objective: Drives a reserved burst type write (AWBURST=2'b11) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_reserved_burst_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_illegal_reserved_burst_write)

  function new(string name = "seq_illegal_reserved_burst_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_ILLEGAL_RSVD_WRITE", "Executing Sequence #16: Illegal Reserved Write Burst", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h2;
    wr_seq.seq_addr = 16'h0020;
    wr_seq.seq_len  = 8'h01;
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b11; // Reserved burst encoding
    wr_seq.allow_illegal = 1;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b10;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_RSVD_WRITE", "Sequence #16 completed", UVM_LOW)
  endtask

endclass
