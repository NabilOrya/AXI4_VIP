// Sequence #38: seq_fifo_push_pop_basic
// Features: F26–F28 (FIFO Basic Push, Pop & Level Tracking)
// Objective: Pushes multiple 32-bit entries into FIFO and pops them back, verifying occupancy tracking.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_push_pop_basic extends axi4_vseq_base;
  `uvm_object_utils(seq_fifo_push_pop_basic)

  function new(string name = "seq_fifo_push_pop_basic");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_FIFO_PUSH_POP_BASIC", "Executing Sequence #38: FIFO Basic Push/Pop Test", UVM_LOW)

    // Enable FIFO (CTRL.fifo_en = 1 -> 0x2)
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id       = 4'h0;
    wr_seq.seq_addr     = 16'h1000;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000002;
    start_write(wr_seq);

    // Push 4 entries
    for (int i = 0; i < 4; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("push_%0d", i));
      wr_seq.seq_id       = 4'h0;
      wr_seq.seq_addr     = 16'h1010; // A_FIFO_DATA
      wr_seq.seq_len      = 8'h00;
      wr_seq.seq_size     = 3'b010;
      wr_seq.seq_burst    = 2'b00;
      wr_seq.fixed_strb   = 4'hF;
      wr_seq.override_data= 1;
      wr_seq.seq_data     = new[1];
      wr_seq.seq_data[0]  = 32'hA0A00000 + i;
      start_write(wr_seq);
    end

    // Pop 4 entries
    for (int i = 0; i < 4; i++) begin
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("pop_%0d", i));
      rd_seq.seq_id   = 4'h0;
      rd_seq.seq_addr = 16'h1010; // A_FIFO_DATA
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b00;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_FIFO_PUSH_POP_BASIC", "Sequence #38 completed", UVM_LOW)
  endtask

endclass
