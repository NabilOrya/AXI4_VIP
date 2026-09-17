// Sequence #26: seq_legal_incr_burst_write
// Features: F6, F9 (Legal INCR Burst Write & Address Incrementing)
// Objective: Drives a legal INCR burst write where address increments by transfer size per beat.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_legal_incr_burst_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_legal_incr_burst_write)

  function new(string name = "seq_legal_incr_burst_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_LEGAL_INCR_WRITE", "Executing Sequence #26: Legal INCR Write Burst", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h7;
    wr_seq.seq_addr = 16'h0200;
    wr_seq.seq_len  = 8'h07; // 8 beats
    wr_seq.seq_size = 3'b010; // 4 bytes/beat
    wr_seq.seq_burst= 2'b01; // INCR burst
    wr_seq.check_resp  = 1;
    wr_seq.expect_resp = 2'b00;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_LEGAL_INCR_WRITE", "Sequence #26 completed", UVM_LOW)
  endtask

endclass
