// Sequence #38: seq_fifo_push_pop_basic
// Features: F26-F28
// Objective: Push/pop with known data; FIFO_STATUS level checked via ref/SB.

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

    // Clear any prior contents, then enable
    wr_seq = axi4_write_base_seq::type_id::create("clr_fifo");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000000; // fifo_en=0 clears
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id        = 4'h0;
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

    for (int i = 0; i < 4; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("push_%0d", i));
      wr_seq.seq_id        = 4'h0;
      wr_seq.seq_addr      = 16'h1010;
      wr_seq.seq_len       = 8'h00;
      wr_seq.seq_size      = 3'b010;
      wr_seq.seq_burst     = 2'b00;
      wr_seq.fixed_strb    = 4'hF;
      wr_seq.override_data = 1;
      wr_seq.seq_data      = new[1];
      wr_seq.seq_data[0]   = 32'hA0A00000 + i;
      wr_seq.check_resp    = 1;
      wr_seq.expect_resp   = RESP_OKAY;
      start_write(wr_seq);
    end

    // Level should be 4 (ref/SB)
    rd_seq = axi4_read_base_seq::type_id::create("rd_stat_mid");
    rd_seq.seq_id      = 4'h0;
    rd_seq.seq_addr    = 16'h1014;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    for (int i = 0; i < 4; i++) begin
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("pop_%0d", i));
      rd_seq.seq_id      = 4'h0;
      rd_seq.seq_addr    = 16'h1010;
      rd_seq.seq_len     = 8'h00;
      rd_seq.seq_size    = 3'b010;
      rd_seq.seq_burst   = 2'b00;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = RESP_OKAY;
      start_read(rd_seq);
    end

    rd_seq = axi4_read_base_seq::type_id::create("rd_stat_end");
    rd_seq.seq_id      = 4'h0;
    rd_seq.seq_addr    = 16'h1014;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    `uvm_info("SEQ_FIFO_PUSH_POP_BASIC", "Sequence #38 completed", UVM_LOW)
  endtask

endclass
