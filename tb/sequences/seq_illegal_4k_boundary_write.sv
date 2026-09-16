// Sequence #22: seq_illegal_4k_boundary_write
// Feature: F13 (4 KiB Boundary Crossing Rejection - Write)
// Objective: Drives an INCR write burst whose address range crosses a 4 KiB boundary, verifying SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_4k_boundary_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_illegal_4k_boundary_write)

  function new(string name = "seq_illegal_4k_boundary_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_ILLEGAL_4K_WRITE", "Executing Sequence #22: Illegal 4KB Boundary Write", UVM_LOW)

    // Start address 0x0FE0, len=15 (16 beats), size=2 (4 bytes/beat) -> last beat address 0x101C (crosses 0x1000)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h5;
    wr_seq.seq_addr = 16'h0FE0;
    wr_seq.seq_len  = 8'h0F; // 16 beats
    wr_seq.seq_size = 3'b010; // 4 bytes/beat -> 64 bytes total span
    wr_seq.seq_burst= 2'b01; // INCR
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b10;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_4K_WRITE", "Sequence #22 completed", UVM_LOW)
  endtask

endclass
