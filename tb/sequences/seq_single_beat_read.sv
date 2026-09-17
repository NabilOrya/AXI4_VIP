// Sequence #31: seq_single_beat_read
// Feature: F7 (Single-Beat Read Transfer)
// Objective: Drives a single-beat read (ARLEN=0) to test baseline single-transfer handling.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_single_beat_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_single_beat_read)

  function new(string name = "seq_single_beat_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_SINGLE_BEAT_READ", "Executing Sequence #31: Single-Beat Read", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h9;
    rd_seq.seq_addr = 16'h0050;
    rd_seq.seq_len  = 8'h00; // Single beat (len=0)
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b01;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = 2'b00;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_SINGLE_BEAT_READ", "Sequence #31 completed", UVM_LOW)
  endtask

endclass
