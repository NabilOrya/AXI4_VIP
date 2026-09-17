// Sequence #40: seq_fifo_underflow_pop_while_empty
// Feature: F27 (FIFO Underflow Pop-While-Empty)
// Objective: Force FIFO empty, then pop. RTL/Appendix A: silent OKAY (no error).
//            Self-contained so it does not depend on prior overflow leaving FIFO full.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_fifo_underflow_pop_while_empty extends axi4_vseq_base;
  `uvm_object_utils(seq_fifo_underflow_pop_while_empty)

  function new(string name = "seq_fifo_underflow_pop_while_empty");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_FIFO_UNDERFLOW", "Executing Sequence #40: FIFO Underflow Pop-While-Empty", UVM_LOW)

    resolve_handles();

    // Clear FIFO via fifo_en=0, then re-enable (guaranteed empty)
    wr_seq = axi4_write_base_seq::type_id::create("clr");
    wr_seq.seq_id        = 4'h2;
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
    wr_seq.seq_id        = 4'h2;
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

    rd_seq = axi4_read_base_seq::type_id::create("rd_stat");
    rd_seq.seq_id      = 4'h2;
    rd_seq.seq_addr    = 16'h1014;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    // Pop while empty - expect OKAY (RTL absorbs; ref matches Appendix A)
    rd_seq = axi4_read_base_seq::type_id::create("empty_pop");
    rd_seq.seq_id      = 4'h2;
    rd_seq.seq_addr    = 16'h1010;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    `uvm_info("SEQ_FIFO_UNDERFLOW", "Sequence #40 completed", UVM_LOW)
  endtask

endclass
