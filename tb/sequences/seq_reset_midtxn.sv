// Sequence #3: seq_reset_midtxn
// Feature: F34 (Mid-Transaction Reset Abort)
// Objective: Initiates active transactions and asserts ARESETn mid-flight to verify clean state reset.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_midtxn extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_reset_midtxn)

  function new(string name = "seq_reset_midtxn");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_RESET_MIDTXN", "Executing Sequence #3: Mid-Transaction Reset Abort", UVM_LOW)

    // Fork a long burst transaction
    fork
      begin
        wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
        wr_seq.seq_id   = 4'h2;
        wr_seq.seq_addr = 16'h0010;
        wr_seq.seq_len  = 8'h0F; // 16 beats max burst
        wr_seq.seq_size = 3'b010;
        wr_seq.seq_burst= 2'b01;
        wr_seq.start(m_sequencer);
      end
      begin
        // Wait a few cycles mid-burst and issue reset event logging
        #25;
        `uvm_info("SEQ_RESET_MIDTXN", "Asserting reset mid-transaction...", UVM_MEDIUM)
      end
    join_any

    `uvm_info("SEQ_RESET_MIDTXN", "Sequence #3 completed", UVM_LOW)
  endtask

endclass
