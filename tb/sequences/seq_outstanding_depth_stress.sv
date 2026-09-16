// Sequence #48: seq_outstanding_depth_stress
// Features: F2, F3, F32, F33 (Outstanding Request Queue Depth Stress - QDEPTH=4)
// Objective: Issues 5+ queued write transactions back-to-back to hit QDEPTH=4 queue limit and verify AWREADY stalling.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_outstanding_depth_stress extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_outstanding_depth_stress)

  function new(string name = "seq_outstanding_depth_stress");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_OUTSTANDING_STRESS", "Executing Sequence #48: Outstanding Queue Depth Stress", UVM_LOW)

    // Issue 5 consecutive write transactions (QDEPTH = 4 -> 5th must stall)
    for (int i = 0; i < 5; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("wr_queue_%0d", i));
      wr_seq.seq_id   = i[3:0];
      wr_seq.seq_addr = 16'h0000 + (i * 16);
      wr_seq.seq_len  = 8'h01; // 2 beats
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b01;
      wr_seq.start(m_sequencer);
    end

    `uvm_info("SEQ_OUTSTANDING_STRESS", "Sequence #48 completed", UVM_LOW)
  endtask

endclass
