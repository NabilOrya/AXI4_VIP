// Sequence #49: seq_backpressure_sweep
// Features: F21, F29, F36, F37 (Backpressure Delays & Channel Stall Sweep)
// Objective: Configures maximum DELAY_CFG and enables delay_en to test slave response stretching.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_backpressure_sweep extends axi4_vseq_base;
  `uvm_object_utils(seq_backpressure_sweep)

  function new(string name = "seq_backpressure_sweep");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_BACKPRESSURE_SWEEP", "Executing Sequence #49: Slave Backpressure Delays Sweep", UVM_LOW)

    // Step 1: Set maximum DELAY_CFG (0xFF -> max write delay=15, max read delay=15)
    wr_seq = axi4_write_base_seq::type_id::create("wr_delaycfg");
    wr_seq.seq_id       = 4'h0;
    wr_seq.seq_addr     = 16'h1018; // A_DELAY_CFG
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h000000FF;
    start_write(wr_seq);

    // Step 2: Enable delay_en in CTRL (bit2 = 1 -> 0x4)
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id       = 4'h0;
    wr_seq.seq_addr     = 16'h1000; // A_CTRL
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000004; // delay_en=1
    start_write(wr_seq);

    // Step 3: Run write and read bursts under maximum backpressure
    wr_seq = axi4_write_base_seq::type_id::create("wr_stressed");
    wr_seq.seq_id   = 4'h1;
    wr_seq.seq_addr = 16'h0100;
    wr_seq.seq_len  = 8'h03; // 4 beats
    wr_seq.seq_size = 3'b010;
    wr_seq.seq_burst= 2'b01;
    start_write(wr_seq);

    rd_seq = axi4_read_base_seq::type_id::create("rd_stressed");
    rd_seq.seq_id   = 4'h1;
    rd_seq.seq_addr = 16'h0100;
    rd_seq.seq_len  = 8'h03; // 4 beats
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b01;
    start_read(rd_seq);

    `uvm_info("SEQ_BACKPRESSURE_SWEEP", "Sequence #49 completed", UVM_LOW)
  endtask

endclass
