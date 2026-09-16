// Sequence #8: seq_reg_fifo_data_access
// Features: F26, F27 (FIFO Push via FIFO_DATA Write & Pop via Read)
// Objective: Enables FIFO in CTRL, performs push to FIFO_DATA (0x1010) with full strobe 0xF, then reads to pop.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_fifo_data_access extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_fifo_data_access)

  function new(string name = "seq_reg_fifo_data_access");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_FIFO_DATA_ACCESS", "Executing Sequence #8: FIFO_DATA Push/Pop Access", UVM_LOW)

    // Step 1: Enable FIFO in CTRL (bit1 = 1 -> CTRL = 0x2)
    wr_seq = axi4_write_base_seq::type_id::create("wr_ctrl");
    wr_seq.seq_id       = 4'h4;
    wr_seq.seq_addr     = 16'h1000; // A_CTRL
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000002; // fifo_en=1
    start_write(wr_seq);

    // Step 2: Push word to FIFO_DATA (0x1010) with full WSTRB=0xF
    wr_seq = axi4_write_base_seq::type_id::create("wr_fifo");
    wr_seq.seq_id       = 4'h4;
    wr_seq.seq_addr     = 16'h1010; // A_FIFO_DATA
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.fixed_strb   = 4'hF;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'hDEADBEEF;
    start_write(wr_seq);

    // Step 3: Pop word from FIFO_DATA via Read
    rd_seq = axi4_read_base_seq::type_id::create("rd_fifo");
    rd_seq.seq_id   = 4'h4;
    rd_seq.seq_addr = 16'h1010; // A_FIFO_DATA
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    start_read(rd_seq);

    `uvm_info("SEQ_REG_FIFO_DATA_ACCESS", "Sequence #8 completed", UVM_LOW)
  endtask

endclass
