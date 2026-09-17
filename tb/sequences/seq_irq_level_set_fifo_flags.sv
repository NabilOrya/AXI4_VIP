// Sequence #47: seq_irq_level_set_fifo_flags
// Feature: F24 (INT_STATUS level-set empty/full)
// Objective: After real reset, empty is set; W1C of empty re-asserts; full sets when FIFO full.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_irq_level_set_fifo_flags extends axi4_vseq_base;
  `uvm_object_utils(seq_irq_level_set_fifo_flags)

  function new(string name = "seq_irq_level_set_fifo_flags");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;

    `uvm_info("SEQ_IRQ_LEVEL_SET", "Executing Sequence #47: INT_STATUS Level-Set FIFO Flags Check", UVM_LOW)

    resolve_handles();
    pulse_reset();

    // --- Empty flag after reset ---
    rd_seq = axi4_read_base_seq::type_id::create("rd_empty");
    rd_seq.seq_id      = 4'h4;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h2) == 0)
      `uvm_error("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS[1] not set post-reset: got=0x%0h", rd_seq.last_rdata))

    // W1C clear empty while still empty -> must re-set (level-set)
    wr_seq = axi4_write_base_seq::type_id::create("w1c_empty");
    wr_seq.seq_id        = 4'h4;
    wr_seq.seq_addr      = 16'h100C;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000002;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    rd_seq = axi4_read_base_seq::type_id::create("rd_empty_again");
    rd_seq.seq_id      = 4'h4;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h2) == 0)
      `uvm_error("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS[1] did not re-assert after W1C while empty: got=0x%0h",
                  rd_seq.last_rdata))

    // --- Full flag: enable FIFO, push 16 entries ---
    wr_seq = axi4_write_base_seq::type_id::create("en_fifo");
    wr_seq.seq_id        = 4'h4;
    wr_seq.seq_addr      = 16'h1000;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b00;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'h00000002; // fifo_en
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    for (int i = 0; i < 16; i++) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("push_%0d", i));
      wr_seq.seq_id        = 4'h4;
      wr_seq.seq_addr      = 16'h1010;
      wr_seq.seq_len       = 8'h00;
      wr_seq.seq_size      = 3'b010;
      wr_seq.seq_burst     = 2'b00;
      wr_seq.fixed_strb    = 4'hF;
      wr_seq.override_data = 1;
      wr_seq.seq_data      = new[1];
      wr_seq.seq_data[0]   = 32'hF1000000 + i;
      wr_seq.check_resp    = 1;
      wr_seq.expect_resp   = RESP_OKAY;
      start_write(wr_seq);
    end

    rd_seq = axi4_read_base_seq::type_id::create("rd_full");
    rd_seq.seq_id      = 4'h4;
    rd_seq.seq_addr    = 16'h100C;
    rd_seq.seq_len     = 8'h00;
    rd_seq.seq_size    = 3'b010;
    rd_seq.seq_burst   = 2'b00;
    rd_seq.check_resp  = 1;
    rd_seq.expect_resp = RESP_OKAY;
    start_read(rd_seq);
    if ((rd_seq.last_rdata & 32'h1) == 0)
      `uvm_error("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS[0] (fifo full) not set: got=0x%0h", rd_seq.last_rdata))
    if ((rd_seq.last_rdata & 32'h2) != 0)
      `uvm_error("SEQ_IRQ_LEVEL_SET",
        $sformatf("INT_STATUS[1] still set while FIFO full: got=0x%0h", rd_seq.last_rdata))

    `uvm_info("SEQ_IRQ_LEVEL_SET", "Sequence #47 completed", UVM_LOW)
  endtask

endclass
