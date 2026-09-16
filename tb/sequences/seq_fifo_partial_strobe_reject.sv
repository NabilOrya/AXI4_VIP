// Sequence #42: seq_fifo_partial_strobe_reject
// Feature: F26 (FIFO Push Strobe Validation)
// Objective: Attempts push to FIFO_DATA (0x1010) with partial byte strobe (WSTRB != 4'hF) and verifies SLVERR response.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_partial_strobe_reject extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_fifo_partial_strobe_reject)

  function new(string name = "seq_fifo_partial_strobe_reject");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_FIFO_PARTIAL_STROBE", "Executing Sequence #42: FIFO Partial Strobe Reject", UVM_LOW)

    // Enable FIFO
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id       = 4'h4;
    wr_seq.seq_addr     = 16'h1000;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000002;
    wr_seq.check_resp   = 1;
    wr_seq.expect_resp  = 2'b00;
    wr_seq.start(m_sequencer);

    // Write to FIFO_DATA with partial WSTRB = 4'h1 (Illegal for FIFO)
    wr_seq = axi4_write_base_seq::type_id::create("partial_push");
    wr_seq.seq_id       = 4'h4;
    wr_seq.seq_addr     = 16'h1010;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.fixed_strb   = 4'h1; // Partial strobe (Illegal)
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h12345678;
    wr_seq.check_resp   = 1;
    wr_seq.expect_resp  = 2'b10; // SLVERR
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_FIFO_PARTIAL_STROBE", "Sequence #42 completed", UVM_LOW)
  endtask

endclass
