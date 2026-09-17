// Sequence #9: seq_reg_fifo_status_ro_check
// Features: F18, F28 (FIFO_STATUS Read-Only Protection & Occupancy Accuracy Check)
// Objective: Attempts write to FIFO_STATUS (0x1014) to verify RO protection, and reads level/flags.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_fifo_status_ro_check extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_fifo_status_ro_check)

  function new(string name = "seq_reg_fifo_status_ro_check");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_FIFO_STATUS_RO_CHECK", "Executing Sequence #9: FIFO_STATUS RO Check", UVM_LOW)

    // Attempt illegal write to RO FIFO_STATUS register (0x1014)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id       = 4'h5;
    wr_seq.seq_addr     = 16'h1014; // A_FIFO_STAT
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h12345678;
    wr_seq.check_resp   = 1;
    wr_seq.expect_resp  = RESP_SLVERR;
    start_write(wr_seq);

    // Read FIFO_STATUS to verify occupancy level and flags
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id      = 4'h5;
    rd_seq.seq_addr    = 16'h1014;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_FIFO_STATUS_RO_CHECK", "Sequence #9 completed", UVM_LOW)
  endtask

endclass
