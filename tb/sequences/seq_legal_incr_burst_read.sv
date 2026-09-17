// Sequence #27: seq_legal_incr_burst_read
// Features: F7, F9 (Legal INCR Burst Read & Address Incrementing)
// Objective: Drives a legal INCR burst read where address increments by transfer size per beat.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_legal_incr_burst_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_legal_incr_burst_read)

  function new(string name = "seq_legal_incr_burst_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_LEGAL_INCR_READ", "Executing Sequence #27: Legal INCR Read Burst", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h7;
    rd_seq.seq_addr = 16'h0200;
    rd_seq.seq_len  = 8'h07; // 8 beats
    rd_seq.seq_size = 3'b010; // 4 bytes/beat
    rd_seq.seq_burst= 2'b01; // INCR burst
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_LEGAL_INCR_READ", "Sequence #27 completed", UVM_LOW)
  endtask

endclass
