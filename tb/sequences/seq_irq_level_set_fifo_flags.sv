// Sequence #47: seq_irq_level_set_fifo_flags
// Feature: F24 (INT_STATUS Level-Set FIFO Flags Check)
// Objective: Verifies INT_STATUS[1] (empty) is level-set post-reset.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_level_set_fifo_flags extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_level_set_fifo_flags)

  function new(string name = "seq_irq_level_set_fifo_flags");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_base_seq rd_seq;

    `uvm_info("SEQ_IRQ_LEVEL_SET", "Executing Sequence #47: INT_STATUS Level-Set FIFO Flags Check", UVM_LOW)

    // Read INT_STATUS post-reset (FIFO starts empty -> bit1 must be set)
    rd_seq = axi4_read_base_seq::type_id::create("rd_intstat");
    rd_seq.seq_id      = 4'h4;
    rd_seq.seq_addr    = 16'h100C; // A_INT_STATUS
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);

    if ((rd_seq.last_rdata & 32'h2) == 0)
      `uvm_error("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS[1] (fifo empty) not set post-reset: got=0x%0h", rd_seq.last_rdata))
    else
      `uvm_info("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS empty flag set as expected: 0x%0h", rd_seq.last_rdata), UVM_MEDIUM)

    `uvm_info("SEQ_IRQ_LEVEL_SET", "Sequence #47 completed", UVM_LOW)
  endtask

endclass
