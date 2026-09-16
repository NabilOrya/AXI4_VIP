// Sequence #23: seq_illegal_4k_boundary_read
// Feature: F13 (4 KiB Boundary Crossing Rejection - Read)
// Objective: Drives an INCR read burst whose address range crosses a 4 KiB boundary, verifying SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_illegal_4k_boundary_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_illegal_4k_boundary_read)

  function new(string name = "seq_illegal_4k_boundary_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_ILLEGAL_4K_READ", "Executing Sequence #23: Illegal 4KB Boundary Read", UVM_LOW)

    // Start address 0x0FE0, len=15 (16 beats), size=2 (4 bytes/beat) -> last beat address 0x101C (crosses 0x1000)
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h5;
    rd_seq.seq_addr = 16'h0FE0;
    rd_seq.seq_len  = 8'h0F; // 16 beats
    rd_seq.seq_size = 3'b010; // 4 bytes/beat
    rd_seq.seq_burst= 2'b01; // INCR
    rd_seq.check_resp    = 1;
    rd_seq.expect_resp   = 2'b10;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_ILLEGAL_4K_READ", "Sequence #23 completed", UVM_LOW)
  endtask

endclass
