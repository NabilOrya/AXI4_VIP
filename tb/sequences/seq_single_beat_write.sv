// Sequence #30: seq_single_beat_write
// Features: F4, F6 (Single-Beat Write Transfer)
// Objective: Drives a single-beat write (AWLEN=0) to test baseline single-transfer handling.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_single_beat_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_single_beat_write)

  function new(string name = "seq_single_beat_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_SINGLE_BEAT_WRITE", "Executing Sequence #30: Single-Beat Write", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h9;
    wr_seq.seq_addr = 16'h0050;
    wr_seq.seq_len  = 8'h00; // Single beat (len=0)
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b01;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_SINGLE_BEAT_WRITE", "Sequence #30 completed", UVM_LOW)
  endtask

endclass
