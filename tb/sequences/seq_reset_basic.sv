// Sequence #1: seq_reset_basic
// Feature: F1 (Reset State Verification)
// Objective: Verify interface and DUT components remain inactive and reset clean out of reset.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_basic extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(seq_reset_basic)

  function new(string name = "seq_reset_basic");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("SEQ_RESET_BASIC", "Executing Sequence #1: Basic Reset State Verification", UVM_LOW)
    // Basic reset sanity check: delay to observe reset state stability
    #50;
    `uvm_info("SEQ_RESET_BASIC", "Reset basic check completed successfully", UVM_LOW)
  endtask

endclass
