// Sequence #24: seq_legal_fixed_burst_write
// Features: F6, F8 (Legal FIXED Burst Write & Address Stability)
// Objective: Drives a legal FIXED burst write where address remains constant across all beats.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_legal_fixed_burst_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_legal_fixed_burst_write)

  function new(string name = "seq_legal_fixed_burst_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_LEGAL_FIXED_WRITE", "Executing Sequence #24: Legal FIXED Write Burst", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h6;
    wr_seq.seq_addr = 16'h0100;
    wr_seq.seq_len  = 8'h03; // 4 beats
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b00; // FIXED burst
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_LEGAL_FIXED_WRITE", "Sequence #24 completed", UVM_LOW)
  endtask

endclass
