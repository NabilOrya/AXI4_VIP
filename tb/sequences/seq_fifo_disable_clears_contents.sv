// Sequence #41: seq_fifo_disable_clears_contents
// Feature: F20 (CTRL fifo_en Disable Clears FIFO Contents)
// Objective: Pushes items to FIFO, then disables fifo_en in CTRL to verify FIFO memory and level clear immediately.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_disable_clears_contents extends axi4_vseq_base;
  `uvm_object_utils(seq_fifo_disable_clears_contents)

  function new(string name = "seq_fifo_disable_clears_contents");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_FIFO_DISABLE_CLEAR", "Executing Sequence #41: FIFO Disable Clears Contents", UVM_LOW)

    // Step 1: Enable FIFO (fifo_en = 1 -> 0x2)
    wr_seq = axi4_write_base_seq::type_id::create("en_fifo");
    wr_seq.seq_id       = 4'h3;
    wr_seq.seq_addr     = 16'h1000;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000002;
    start_write(wr_seq);

    // Step 2: Push 3 items
    for (int i = 0; i < 3; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("push_%0d", i));
      wr_seq.seq_id       = 4'h3;
      wr_seq.seq_addr     = 16'h1010;
      wr_seq.seq_len      = 8'h00;
      wr_seq.seq_size     = 3'b010;
      wr_seq.seq_burst    = 2'b00;
      wr_seq.fixed_strb   = 4'hF;
      wr_seq.override_data= 1;
      wr_seq.seq_data     = new[1];
      wr_seq.seq_data[0]  = 32'hC0C00000 + i;
      start_write(wr_seq);
    end

    // Step 3: Disable FIFO (fifo_en = 0 -> 0x0)
    wr_seq = axi4_write_base_seq::type_id::create("dis_fifo");
    wr_seq.seq_id       = 4'h3;
    wr_seq.seq_addr     = 16'h1000;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000000;
    start_write(wr_seq);

    // Step 4: Read FIFO_STATUS (0x1014) to verify level=0 and empty=1
    rd_seq = axi4_read_base_seq::type_id::create("rd_stat");
    rd_seq.seq_id   = 4'h3;
    rd_seq.seq_addr = 16'h1014;
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    start_read(rd_seq);

    `uvm_info("SEQ_FIFO_DISABLE_CLEAR", "Sequence #41 completed", UVM_LOW)
  endtask

endclass
