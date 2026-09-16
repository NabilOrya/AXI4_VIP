// Sequence #40: seq_fifo_underflow_pop_while_empty
// Feature: F27 (FIFO Underflow Pop-While-Empty Check)
// Objective: Issues pop read request to FIFO_DATA (0x1010) while empty to verify absorption / error handling.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_underflow_pop_while_empty extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(seq_fifo_underflow_pop_while_empty)

  function new(string name = "seq_fifo_underflow_pop_while_empty");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_FIFO_UNDERFLOW", "Executing Sequence #40: FIFO Underflow Pop-While-Empty", UVM_LOW)

    // Read from FIFO_DATA while FIFO is completely empty
    rd_seq = axi4_read_base_seq::type_id::create("empty_pop");
    rd_seq.seq_id   = 4'h2;
    rd_seq.seq_addr = 16'h1010; // A_FIFO_DATA
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    rd_seq.start(m_sequencer);

    `uvm_info("SEQ_FIFO_UNDERFLOW", "Sequence #40 completed", UVM_LOW)
  endtask

endclass
