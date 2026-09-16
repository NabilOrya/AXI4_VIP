// Sequence #20: seq_illegal_size_gt2_write
// Feature: F12 (Transfer Size Limit Rejection - Write)
// Objective: Drives AWSIZE > 2 (size=3, i.e. 8 bytes/beat on 32-bit bus) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_size_gt2_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_illegal_size_gt2_write)

  function new(string name = "seq_illegal_size_gt2_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_ILLEGAL_SIZE_WRITE", "Executing Sequence #20: Illegal Transfer Size Write (>2)", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h4;
    wr_seq.seq_addr = 16'h0000;
    wr_seq.seq_len  = 8'h00;
    wr_seq.seq_size = 3'b011; // size=3 (8 bytes, unsupported)
    wr_seq.seq_burst= 2'b01;
    wr_seq.allow_illegal = 1;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b10;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_SIZE_WRITE", "Sequence #20 completed", UVM_LOW)
  endtask

endclass
