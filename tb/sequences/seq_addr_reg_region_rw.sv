// Sequence #34: seq_addr_reg_region_rw
// Feature: F15 (Address Decode — Register Region 0x1000–0x101C)
// Objective: Sweeps defined register addresses to verify legal region decode returning OKAY.
// Note: FIFO_DATA writes need CTRL.fifo_en=1 (and full WSTRB); otherwise DUT correctly returns SLVERR.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_reg_region_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_reg_region_rw)

  function new(string name = "seq_addr_reg_region_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    // CTRL last so a random CTRL write cannot clear fifo_en before FIFO_DATA
    bit [15:0] reg_addrs[4] = '{16'h1008, 16'h1010, 16'h1018, 16'h1000}; // INT_EN, FIFO_DATA, DELAY_CFG, CTRL

    `uvm_info("SEQ_ADDR_REG_RW", "Executing Sequence #34: Register Region Address Decode Sweep", UVM_LOW)

    // Enable FIFO so FIFO_DATA is a legal mapped write (OKAY), not a misuse SLVERR
    wr_seq = axi4_write_base_seq::type_id::create("wr_en_fifo");
    wr_seq.seq_id        = 4'h1;
    wr_seq.seq_addr      = 16'h1000; // CTRL
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h0000_0002; // fifo_en=1
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = 2'b00;
    start_write(wr_seq);

    foreach (reg_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id      = 4'h1;
      wr_seq.seq_addr    = reg_addrs[i];
      wr_seq.seq_len     = 8'h00;
      wr_seq.seq_size    = 3'b010;
      wr_seq.seq_burst   = 2'b00;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b00;
      // FIFO_DATA requires full-word strobe (default fixed_strb=0xF already)
      if (reg_addrs[i] == 16'h1010) begin
        wr_seq.override_data = 1;
        wr_seq.seq_data      = new[1];
        wr_seq.seq_data[0]   = 32'hA5A5_A5A5;
      end
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id      = 4'h1;
      rd_seq.seq_addr    = reg_addrs[i];
      rd_seq.seq_len     = 8'h00;
      rd_seq.seq_size    = 3'b010;
      rd_seq.seq_burst   = 2'b00;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b00;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_REG_RW", "Sequence #34 completed", UVM_LOW)
  endtask

endclass
