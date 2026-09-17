// Sequence #2: seq_reset_readback_zero
// Feature: F1 (Reset Readback Verification)
// Objective: After reset, read RAM / regs. Expected RDATA comes from the
// reference model via the scoreboard (including F24 level-set INT_STATUS[1]
// and STATUS/FIFO_STATUS empty flags). Do not hardcode DUT-friendly values.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_readback_zero extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_reset_readback_zero)

  function new(string name = "seq_reset_readback_zero");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;
    // TXN_COUNT first: each completed burst increments it, so only the first
    // post-reset read of 0x101C can prove a true zero count.
    bit [15:0] target_addrs[] = '{
      16'h101C, // TXN_COUNT  (expect 0 via ref/SB)
      16'h0000, // RAM start
      16'h0800, // RAM mid
      16'h0FFC, // RAM end word
      16'h1000, // CTRL
      16'h1004, // STATUS     (empty + rd_busy — not all-zero; SB vs ref)
      16'h1008, // INT_EN
      16'h100C, // INT_STATUS (F24: empty bit level-set; SB vs ref)
      16'h1014, // FIFO_STATUS
      16'h1018  // DELAY_CFG
    };

    `uvm_info("SEQ_RESET_READBACK_ZERO",
              "Executing Sequence #2: Reset Readback (ref/SB expected values)", UVM_LOW)

    foreach (target_addrs[i]) begin
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("rd_seq_%0d", i));
      rd_seq.seq_id      = 4'h1;
      rd_seq.seq_addr    = target_addrs[i];
      rd_seq.seq_len     = 8'h00;
      rd_seq.seq_size    = 3'b010;
      rd_seq.seq_burst   = 2'b01;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b00; // OKAY
      // Data checking is intentionally left to ref_model + scoreboard so a
      // DUT mismatch surfaces as SCOREBOARD RD DATA / RESP errors.
      rd_seq.start(m_sequencer);
    end

    `uvm_info("SEQ_RESET_READBACK_ZERO", "Sequence #2 completed", UVM_LOW)
  endtask

endclass
