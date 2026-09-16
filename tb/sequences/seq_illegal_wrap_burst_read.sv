// Sequence #15: seq_illegal_wrap_burst_read
// Feature: F10 (WRAP Burst Rejection - Read)
// Objective: Drives a WRAP burst read (ARBURST=2'b10) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_wrap_burst_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_illegal_wrap_burst_read)

  function new(string name = "seq_illegal_wrap_burst_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_ILLEGAL_WRAP_READ", "Executing Sequence #15: Illegal WRAP Read Burst", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h1;
    rd_seq.seq_addr = 16'h0010;
    rd_seq.seq_len  = 8'h03; // 4 beats
    rd_seq.seq_size = 3'b010; // 4 bytes
    rd_seq.seq_burst= 2'b10; // WRAP burst (Illegal for DUT)
    rd_seq.allow_illegal = 1;
    rd_seq.check_resp    = 1;
    rd_seq.expect_resp   = 2'b10;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_WRAP_READ", "Sequence #15 completed", UVM_LOW)
  endtask

endclass
