// Sequence #39: seq_fifo_overflow_push_while_full
// Feature: F26 (FIFO Overflow Protection Check)
// Objective: Fills 16 entries into FIFO to reach full state, then attempts a 17th push to verify SLVERR rejection.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_overflow_push_while_full extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_fifo_overflow_push_while_full)

  function new(string name = "seq_fifo_overflow_push_while_full");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;

    `uvm_info("SEQ_FIFO_OVERFLOW", "Executing Sequence #39: FIFO Overflow Push-While-Full", UVM_LOW)

    // Enable FIFO
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id       = 4'h1;
    wr_seq.seq_addr     = 16'h1000;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000002;
    wr_seq.start(m_sequencer);

    // Push 16 entries (Fill depth)
    for (int i = 0; i < 16; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("fill_%0d", i));
      wr_seq.seq_id       = 4'h1;
      wr_seq.seq_addr     = 16'h1010;
      wr_seq.seq_len      = 8'h00;
      wr_seq.seq_size     = 3'b010;
      wr_seq.seq_burst    = 2'b00;
      wr_seq.fixed_strb   = 4'hF;
      wr_seq.override_data= 1;
      wr_seq.seq_data     = new[1];
      wr_seq.seq_data[0]  = 32'hB0B00000 + i;
      wr_seq.start(m_sequencer);
    end

    // Attempt 17th push (Overflow attempt)
    wr_seq = axi4_write_base_seq::type_id::create("overflow_push");
    wr_seq.seq_id       = 4'h1;
    wr_seq.seq_addr     = 16'h1010;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.fixed_strb   = 4'hF;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'hBAD00000;
    wr_seq.check_resp   = 1;
    wr_seq.expect_resp  = 2'b10; // SLVERR on overflow
    wr_seq.start(m_sequencer);

    `uvm_info("SEQ_FIFO_OVERFLOW", "Sequence #39 completed", UVM_LOW)
  endtask

endclass
