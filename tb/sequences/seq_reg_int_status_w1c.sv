// Sequence #7: seq_reg_int_status_w1c
// Features: F23, F25 (INT_STATUS Write-1-to-Clear Behavior)
// Objective: Reads INT_STATUS register (0x100C) and verifies Write-1-to-Clear functionality.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_int_status_w1c extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_int_status_w1c)

  function new(string name = "seq_reg_int_status_w1c");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_REG_INT_STATUS_W1C", "Executing Sequence #7: INT_STATUS W1C Check", UVM_LOW)

    // Read current INT_STATUS
    rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
    rd_seq.seq_id   = 4'h3;
    rd_seq.seq_addr = 16'h100C; // A_INT_STATUS
    rd_seq.seq_len  = 8'h00;
    rd_seq.seq_size = 3'b010;
    rd_seq.seq_burst= 2'b00;
    start_read(rd_seq);

    // Issue Write 1 to clear bit 2 (error event)
    wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
    wr_seq.seq_id       = 4'h3;
    wr_seq.seq_addr     = 16'h100C;
    wr_seq.seq_len      = 8'h00;
    wr_seq.seq_size     = 3'b010;
    wr_seq.seq_burst    = 2'b00;
    wr_seq.override_data= 1;
    wr_seq.seq_data     = new[1];
    wr_seq.seq_data[0]  = 32'h00000004; // Clear bit 2
    start_write(wr_seq);

    // Read back INT_STATUS to verify cleared bit
    start_read(rd_seq);

    `uvm_info("SEQ_REG_INT_STATUS_W1C", "Sequence #7 completed", UVM_LOW)
  endtask

endclass
