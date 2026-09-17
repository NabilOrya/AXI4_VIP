// Sequence #11: seq_reg_txn_count_ro_check
// Features: F18, F30
// Objective: RO write must SLVERR; counter still increments per completed burst (ref/SB).

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_txn_count_ro_check extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_txn_count_ro_check)

  function new(string name = "seq_reg_txn_count_ro_check");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_TXN_COUNT_RO_CHECK", "Executing Sequence #11: TXN_COUNT RO Check", UVM_LOW)

    rd_seq = axi4_read_base_seq::type_id::create("rd_init");
    rd_seq.seq_id      = 4'h0;
    rd_seq.seq_addr    = 16'h101C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    wr_seq = axi4_write_base_seq::type_id::create("wr_illegal");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h101C;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'hFFFFFFFF;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_SLVERR;
    start_write(wr_seq);

    // One more legal write so F30 increment is observable via ref/SB
    wr_seq = axi4_write_base_seq::type_id::create("wr_ram");
    wr_seq.seq_id        = 4'h0;
    wr_seq.seq_addr      = 16'h0040;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b01;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h1111_2222;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    rd_seq = axi4_read_base_seq::type_id::create("rd_final");
    rd_seq.seq_id      = 4'h0;
    rd_seq.seq_addr    = 16'h101C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_TXN_COUNT_RO_CHECK", "Sequence #11 completed", UVM_LOW)
  endtask

endclass
