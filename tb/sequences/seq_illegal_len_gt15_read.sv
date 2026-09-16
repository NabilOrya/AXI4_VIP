// Sequence #19: seq_illegal_len_gt15_read
// Feature: F11 (Burst Length Limit Rejection - Read)
// Objective: Drives ARLEN > 15 (len=16, i.e. 17 beats) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_len_gt15_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_illegal_len_gt15_read)

  function new(string name = "seq_illegal_len_gt15_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_ILLEGAL_LEN_READ", "Executing Sequence #19: Illegal Burst Length Read (>15)", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h3;
    rd_seq.seq_addr = 16'h0000;
    rd_seq.seq_len  = 8'h10; // len=16 (>15 limit)
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b01;
    rd_seq.allow_illegal = 1;
    rd_seq.check_resp    = 1;
    rd_seq.expect_resp   = 2'b10;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_LEN_READ", "Sequence #19 completed", UVM_LOW)
  endtask

endclass
