// Sequence #1: seq_reset_basic
// Feature: F1 (Reset State Verification)
// Objective: After POR release, DUT must not drive response VALIDs or IRQ.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_basic extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(seq_reset_basic)

  virtual axi4_if vif;
  int unsigned observe_cycles = 10;

  function new(string name = "seq_reset_basic");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("SEQ_RESET_BASIC", "Executing Sequence #1: Basic Reset State Verification", UVM_LOW)

    if (vif == null) begin
      if (!uvm_config_db#(virtual axi4_if)::get(null, get_full_name(), "vif", vif))
        void'(uvm_config_db#(virtual axi4_if)::get(null, "*", "vif", vif));
    end
    if (vif == null)
      `uvm_fatal("SEQ_RESET_BASIC", "vif is null — cannot observe post-reset idle")

    wait (vif.ARESETn === 1'b1);
    repeat (2) @(posedge vif.ACLK);

    // F1: no DUT response VALID / IRQ while bus is idle out of reset
    repeat (observe_cycles) begin
      @(posedge vif.ACLK);
      #1; // allow NBA settle
      if (vif.BVALID !== 1'b0)
        `uvm_error("SEQ_RESET_BASIC", "BVALID asserted while idle out of reset")
      if (vif.RVALID !== 1'b0)
        `uvm_error("SEQ_RESET_BASIC", "RVALID asserted while idle out of reset")
      if (vif.IRQ !== 1'b0)
        `uvm_error("SEQ_RESET_BASIC",
          $sformatf("IRQ=%0b out of reset (expect 0 with irq_en cleared)", vif.IRQ))
    end

    `uvm_info("SEQ_RESET_BASIC", "Sequence #1 completed: post-reset idle checks done", UVM_LOW)
  endtask

endclass
