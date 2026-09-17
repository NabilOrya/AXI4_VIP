// Sequence #39: seq_fifo_overflow_push_while_full
// Feature: F26 (FIFO Overflow Protection)
// Objective: Start from empty, fill 16, confirm full via STATUS, 17th push -> SLVERR.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_overflow_push_while_full extends axi4_vseq_base;
  `uvm_object_utils(seq_fifo_overflow_push_while_full)

  function new(string name = "seq_fifo_overflow_push_while_full");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_FIFO_OVERFLOW", "Executing Sequence #39: FIFO Overflow Push-While-Full", UVM_LOW)

    resolve_handles();

    // Clear then enable
    wr_seq = axi4_write_base_seq::type_id::create("clr");
    wr_seq.seq_id        = 4'h1;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000000;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    wr_seq = axi4_write_base_seq::type_id::create("en");
    wr_seq.seq_id        = 4'h1;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000002;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    for (int i = 0; i < 16; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("fill_%0d", i));
      wr_seq.seq_id        = 4'h1;
      wr_seq.seq_addr      = 16'h1010;
      wr_seq.seq_len       = 8'h00;
      wr_seq.seq_size      = 3'b010;
      wr_seq.seq_burst     = 2'b00;
      wr_seq.fixed_strb    = 4'hF;
      wr_seq.override_data = 1;
      wr_seq.seq_data      = new[1];
      wr_seq.seq_data[0]   = 32'hB0B00000 + i;
      wr_seq.check_resp    = 1;
      wr_seq.expect_resp   = RESP_OKAY;
      start_write(wr_seq);
    end

    rd_seq = axi4_read_base_seq::type_id::create("rd_full_stat");
    rd_seq.seq_id      = 4'h1;
    rd_seq.seq_addr    = 16'h1014;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    wr_seq = axi4_write_base_seq::type_id::create("overflow_push");
    wr_seq.seq_id        = 4'h1;
    wr_seq.seq_addr      = 16'h1010;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.fixed_strb    = 4'hF;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'hBAD00000;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_SLVERR;
    start_write(wr_seq);

    `uvm_info("SEQ_FIFO_OVERFLOW", "Sequence #39 completed", UVM_LOW)
  endtask

endclass
