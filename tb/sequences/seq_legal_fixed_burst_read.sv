// Sequence #25: seq_legal_fixed_burst_read
// Features: F7, F8 (Legal FIXED Burst Read & Address Stability)
// Objective: Drives a legal FIXED burst read where address remains constant across all beats.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_legal_fixed_burst_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_legal_fixed_burst_read)

  function new(string name = "seq_legal_fixed_burst_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_LEGAL_FIXED_READ", "Executing Sequence #25: Legal FIXED Read Burst", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h6;
    rd_seq.seq_addr = 16'h0100;
    rd_seq.seq_len  = 8'h03; // 4 beats
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00; // FIXED burst
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_LEGAL_FIXED_READ", "Sequence #25 completed", UVM_LOW)
  endtask

endclass
