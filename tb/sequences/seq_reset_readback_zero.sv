// Sequence #2: seq_reset_readback_zero
// Feature: F1 (Reset Readback Verification)
// Objective: Issues read transactions to memory and register addresses after reset to ensure all registers and RAM locations reset to zero.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_readback_zero extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_reset_readback_zero)

  function new(string name = "seq_reset_readback_zero");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;
    bit [15:0] target_addrs[4] = '{16'h0000, 16'h0800, 16'h1000, 16'h101C}; // RAM start, RAM mid, CTRL, TXN_COUNT

    `uvm_info("SEQ_RESET_READBACK_ZERO", "Executing Sequence #2: Reset Readback Zero Check", UVM_LOW)

    foreach (target_addrs[i]) begin
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("rd_seq_%0d", i));
      rd_seq.seq_id   = 4'h1;
      rd_seq.seq_addr = target_addrs[i];
      rd_seq.seq_len  = 8'h00; // Single beat
      rd_seq.seq_size = 3'b010; // 4-byte transfer
      rd_seq.seq_burst= 2'b01; // INCR
      rd_seq.start(m_sequencer);
    end

    `uvm_info("SEQ_RESET_READBACK_ZERO", "Sequence #2 completed: All post-reset readbacks executed", UVM_LOW)
  endtask

endclass
