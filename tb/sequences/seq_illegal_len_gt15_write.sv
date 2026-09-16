// Sequence #18: seq_illegal_len_gt15_write
// Feature: F11 (Burst Length Limit Rejection - Write)
// Objective: Drives AWLEN > 15 (len=16, i.e. 17 beats) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_len_gt15_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_illegal_len_gt15_write)

  function new(string name = "seq_illegal_len_gt15_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_ILLEGAL_LEN_WRITE", "Executing Sequence #18: Illegal Burst Length Write (>15)", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h3;
    wr_seq.seq_addr = 16'h0000;
    wr_seq.seq_len  = 8'h10; // len=16 (>15 limit)
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b01;
    wr_seq.allow_illegal = 1;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b10;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_LEN_WRITE", "Sequence #18 completed", UVM_LOW)
  endtask

endclass
