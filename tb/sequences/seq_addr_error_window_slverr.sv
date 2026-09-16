// Sequence #36: seq_addr_error_window_slverr
// Feature: F16 (Address Decode — SLVERR Window 0x2000–0x2FFF)
// Objective: Issues read/write accesses to the dedicated SLVERR error window to verify SLVERR return.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_error_window_slverr extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_error_window_slverr)

  function new(string name = "seq_addr_error_window_slverr");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] err_addrs[2] = '{16'h2000, 16'h2800};

    `uvm_info("SEQ_ADDR_ERR_WINDOW_SLVERR", "Executing Sequence #36: Error Window SLVERR Sweep", UVM_LOW)

    foreach (err_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id   = 4'h3;
      wr_seq.seq_addr = err_addrs[i];
      wr_seq.seq_len  = 8'h00;
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b01;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b10;
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id   = 4'h3;
      rd_seq.seq_addr = err_addrs[i];
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b01;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b10;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_ERR_WINDOW_SLVERR", "Sequence #36 completed", UVM_LOW)
  endtask

endclass
