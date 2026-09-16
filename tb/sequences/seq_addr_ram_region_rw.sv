// Sequence #33: seq_addr_ram_region_rw
// Feature: F14 (Address Decode — RAM Region 0x0000–0x0FFF)
// Objective: Sweeps start, middle, and end addresses in the 4 KiB RAM region with legal write/read returning OKAY.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_addr_ram_region_rw extends axi4_vseq_base;
  `uvm_object_utils(seq_addr_ram_region_rw)

  function new(string name = "seq_addr_ram_region_rw");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] ram_addrs[3] = '{16'h0000, 16'h0800, 16'h0FFC};

    `uvm_info("SEQ_ADDR_RAM_RW", "Executing Sequence #33: RAM Region Address Decode Sweep", UVM_LOW)

    foreach (ram_addrs[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
      wr_seq.seq_id   = 4'h0;
      wr_seq.seq_addr = ram_addrs[i];
      wr_seq.seq_len  = 8'h00;
      wr_seq.seq_size = 3'b010;
      wr_seq.seq_burst= 2'b01;
      wr_seq.check_resp  = 1;
      wr_seq.expect_resp = 2'b00;
      start_write(wr_seq);

      rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
      rd_seq.seq_id   = 4'h0;
      rd_seq.seq_addr = ram_addrs[i];
      rd_seq.seq_len  = 8'h00;
      rd_seq.seq_size = 3'b010;
      rd_seq.seq_burst= 2'b01;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = 2'b00;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_ADDR_RAM_RW", "Sequence #33 completed", UVM_LOW)
  endtask

endclass
