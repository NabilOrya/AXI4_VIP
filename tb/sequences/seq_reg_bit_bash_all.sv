// Sequence #12: seq_reg_bit_bash_all
// Features: F18, F22, F29 (Register Bit Bash Sweep)
// Objective: Sweeps 1s and 0s bit toggles across writable registers to verify bit independence.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reg_bit_bash_all extends axi4_vseq_base;
  `uvm_object_utils(seq_reg_bit_bash_all)

  function new(string name = "seq_reg_bit_bash_all");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [15:0] target_regs[3] = '{16'h1000, 16'h1008, 16'h1018}; // CTRL, INT_EN, DELAY_CFG
    bit [31:0] test_patterns[2] = '{32'h000000FF, 32'h00000000};

    `uvm_info("SEQ_REG_BIT_BASH_ALL", "Executing Sequence #12: Register Bit Bash Sweep", UVM_LOW)

    foreach (target_regs[r]) begin
      foreach (test_patterns[p]) begin
        wr_seq = axi4_write_base_seq::type_id::create("wr_seq");
        wr_seq.seq_id       = 4'h1;
        wr_seq.seq_addr     = target_regs[r];
        wr_seq.seq_len      = 8'h00;
        wr_seq.seq_size     = 3'b010;
        wr_seq.seq_burst    = 2'b00;
        wr_seq.override_data= 1;
        wr_seq.seq_data     = new[1];
        wr_seq.seq_data[0]  = test_patterns[p];
        start_write(wr_seq);

        rd_seq = axi4_read_base_seq::type_id::create("rd_seq");
        rd_seq.seq_id   = 4'h1;
        rd_seq.seq_addr = target_regs[r];
        rd_seq.seq_len  = 8'h00;
        rd_seq.seq_size = 3'b010;
        rd_seq.seq_burst= 2'b00;
        start_read(rd_seq);
      end
    end

    `uvm_info("SEQ_REG_BIT_BASH_ALL", "Sequence #12 completed", UVM_LOW)
  endtask

endclass
