// Sequence #29: seq_max_length_burst_read
// Features: F11, F38 (Maximum Length Burst Read Stress - 16 Beats)
// Objective: Drives maximum legal burst length (ARLEN=15, 16 beats) read from memory.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_max_length_burst_read extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_max_length_burst_read)

  function new(string name = "seq_max_length_burst_read");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_MAX_LEN_READ", "Executing Sequence #29: Maximum Length Read Burst (16 Beats)", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h8;
    rd_seq.seq_addr = 16'h0300;
    rd_seq.seq_len  = 8'h0F; // 16 beats (Maximum legal length)
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b01;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_MAX_LEN_READ", "Sequence #29 completed", UVM_LOW)
  endtask

endclass
