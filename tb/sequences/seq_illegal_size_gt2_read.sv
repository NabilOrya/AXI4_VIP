// Sequence #21: seq_illegal_size_gt2_read
// Feature: F12 (Transfer Size Limit Rejection - Read)
// Objective: Drives ARSIZE > 2 (size=3, i.e. 8 bytes/beat on 32-bit bus) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_size_gt2_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_illegal_size_gt2_read)

  function new(string name = "seq_illegal_size_gt2_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_ILLEGAL_SIZE_READ", "Executing Sequence #21: Illegal Transfer Size Read (>2)", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h4;
    rd_seq.seq_addr = 16'h0000;
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b011; // size=3 (8 bytes, unsupported)
    rd_seq.seq_burst= 2'b01;
    rd_seq.allow_illegal = 1;
    rd_seq.check_resp    = 1;
    rd_seq.expect_resp   = 2'b10;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_SIZE_READ", "Sequence #21 completed", UVM_LOW)
  endtask

endclass
