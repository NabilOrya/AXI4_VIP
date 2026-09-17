// Sequence #28: seq_max_length_burst_write
// Features: F11, F38 (Maximum Length Burst Write Stress - 16 Beats)
// Objective: Drives maximum legal burst length (AWLEN=15, 16 beats) write to memory.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_max_length_burst_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_max_length_burst_write)

  function new(string name = "seq_max_length_burst_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_MAX_LEN_WRITE", "Executing Sequence #28: Maximum Length Write Burst (16 Beats)", UVM_LOW)

    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id   = 4'h8;
    wr_seq.seq_addr = 16'h0300;
    wr_seq.seq_len  = 8'h0F; // 16 beats (Maximum legal length)
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b01;
    wr_seq.check_resp  = 1;
    wr_seq.expect_resp = 2'b00;
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_MAX_LEN_WRITE", "Sequence #28 completed", UVM_LOW)
  endtask

endclass
