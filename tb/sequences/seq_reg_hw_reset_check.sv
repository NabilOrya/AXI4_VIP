// Sequence #13: seq_reg_hw_reset_check
// Feature: F1 (Hardware Reset Defaults Across Register Map)
// Objective: Pulse ARESETn, then read the register map. Ref/SB must predict reset values.
//            Must NOT run as a plain read of already-dirtied state.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_hw_reset_check extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_hw_reset_check)

  function new(string name = "seq_reg_hw_reset_check");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;
    bit [15:0] reg_addrs[8] = '{
      16'h1000, 16'h1004, 16'h1008, 16'h100C,
      16'h1010, 16'h1014, 16'h1018, 16'h101C
    };

    `uvm_info("SEQ_REG_HW_RESET_CHECK", "Executing Sequence #13: Hardware Reset Register Check", UVM_LOW)

    resolve_handles();
    if (vif == null)
      `uvm_fatal("SEQ_REG_HW_RESET_CHECK", "vif is null - cannot pulse ARESETn")

    // Force a real reset so defaults are checked even after prior dirty seqs
    pulse_reset();

    foreach (reg_addrs[i]) begin
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("rd_reg_%0d", i));
      rd_seq.seq_id      = 4'h0;
      rd_seq.seq_addr    = reg_addrs[i];
      rd_seq.seq_len     = 8'h00;
      rd_seq.seq_size    = 3'b010;
      rd_seq.seq_burst   = 2'b00;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = RESP_OKAY;
      // RDATA expected values come from ref_model via scoreboard
      start_read(rd_seq);
    end

    `uvm_info("SEQ_REG_HW_RESET_CHECK", "Sequence #13 completed", UVM_LOW)
  endtask

endclass
