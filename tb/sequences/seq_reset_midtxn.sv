// Sequence #3: seq_reset_midtxn
// Feature: F34 (Mid-Transaction Reset Abort)
// Objective: Dirty state, start a long burst, assert ARESETn mid-flight, then
// read back through monitors → ref → scoreboard. Ref/SB must clear on reset;
// if DUT fails to clear RAM/regs/TXN_COUNT, the scoreboard must fail.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_reset_midtxn extends axi4_vseq_base;
  `uvm_object_utils(seq_reset_midtxn)

  function new(string name = "seq_reset_midtxn");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_dirt;
    axi4_write_base_seq wr_long;
    axi4_read_base_seq  rd_seq;
    bit saw_wbeat;

    resolve_handles();
    if (vif == null)
      `uvm_fatal("SEQ_RESET_MIDTXN", "vif is null — cannot drive ARESETn")
    if (write_seqr == null)
      `uvm_fatal("SEQ_RESET_MIDTXN", "write_seqr is null")
    if (read_seqr == null)
      `uvm_fatal("SEQ_RESET_MIDTXN", "read_seqr is null")

    `uvm_info("SEQ_RESET_MIDTXN", "Executing Sequence #3: Mid-Transaction Reset Abort", UVM_LOW)

    // ---- 1) Dirty observable state (completed txns) ----
    wr_dirt = axi4_write_base_seq::type_id::create("wr_dirt_ram");
    wr_dirt.seq_id       = 4'h3;
    wr_dirt.seq_addr     = 16'h0010;
    wr_dirt.seq_len      = 8'h00;
    wr_dirt.seq_size     = 3'b010;
    wr_dirt.seq_burst    = 2'b01;
    wr_dirt.override_data = 1;
    wr_dirt.seq_data     = new[1];
    wr_dirt.seq_data[0]  = 32'hDEAD_BEEF;
    wr_dirt.fixed_strb   = 4'hF;
    wr_dirt.check_resp   = 1;
    wr_dirt.expect_resp  = RESP_OKAY;
    start_write(wr_dirt);

    wr_dirt = axi4_write_base_seq::type_id::create("wr_dirt_ctrl");
    wr_dirt.seq_id       = 4'h3;
    wr_dirt.seq_addr     = 16'h1000; // CTRL
    wr_dirt.seq_len      = 8'h00;
    wr_dirt.seq_size     = 3'b010;
    wr_dirt.seq_burst    = 2'b01;
    wr_dirt.override_data = 1;
    wr_dirt.seq_data     = new[1];
    wr_dirt.seq_data[0]  = 32'h0000_0007; // irq_en|fifo_en|delay_en
    wr_dirt.fixed_strb   = 4'hF;
    wr_dirt.check_resp   = 1;
    wr_dirt.expect_resp  = RESP_OKAY;
    start_write(wr_dirt);

    // ---- 2) Long burst + mid-flight ARESETn ----
    saw_wbeat = 0;
    fork
      begin
        wr_long = axi4_write_base_seq::type_id::create("wr_long");
        wr_long.seq_id    = 4'h2;
        wr_long.seq_addr  = 16'h0020;
        wr_long.seq_len   = 8'h0F; // 16 beats
        wr_long.seq_size  = 3'b010;
        wr_long.seq_burst = 2'b01;
        wr_long.fixed_strb = 4'hF;
        // No check_resp: reset aborts before B — driver must not false-fail
        start_write(wr_long);
      end
      begin
        // Wait until write-data phase is visibly active, then pulse reset
        fork
          begin
            wait (vif.WVALID === 1'b1 && vif.ARESETn === 1'b1);
            saw_wbeat = 1;
          end
          begin
            repeat (200) @(posedge vif.ACLK);
          end
        join_any
        disable fork;

        if (!saw_wbeat)
          `uvm_error("SEQ_RESET_MIDTXN",
            "Timed out waiting for WVALID before mid-txn reset — burst never entered data phase")

        repeat (2) @(posedge vif.ACLK);
        `uvm_info("SEQ_RESET_MIDTXN", "Asserting ARESETn mid-transaction", UVM_LOW)
        vif.ARESETn <= 1'b0;
        repeat (5) @(posedge vif.ACLK);

        // While held in reset: DUT must not drive response VALIDs (F1/F34)
        if (vif.BVALID !== 1'b0)
          `uvm_error("SEQ_RESET_MIDTXN", "BVALID high while ARESETn=0")
        if (vif.RVALID !== 1'b0)
          `uvm_error("SEQ_RESET_MIDTXN", "RVALID high while ARESETn=0")

        `uvm_info("SEQ_RESET_MIDTXN", "Releasing ARESETn", UVM_LOW)
        vif.ARESETn <= 1'b1;
        repeat (3) @(posedge vif.ACLK);
      end
    join

    // ---- 3) Post-reset readbacks — ref/SB must predict cleared state ----
    // If DUT kept DEAD_BEEF / CTRL=7 / non-zero TXN_COUNT, scoreboard fails.
    begin
      bit [15:0] check_addrs[] = '{
        16'h101C, // TXN_COUNT
        16'h0010, // previously dirtied RAM
        16'h1000, // CTRL
        16'h1008, // INT_EN
        16'h1018  // DELAY_CFG
      };
      foreach (check_addrs[i]) begin
        rd_seq = axi4_read_base_seq::type_id::create($sformatf("rd_post_rst_%0d", i));
        rd_seq.seq_id      = 4'h4;
        rd_seq.seq_addr    = check_addrs[i];
        rd_seq.seq_len     = 8'h00;
        rd_seq.seq_size    = 3'b010;
        rd_seq.seq_burst   = 2'b01;
        rd_seq.check_resp  = 1;
        rd_seq.expect_resp = RESP_OKAY;
        start_read(rd_seq);
      end
    end

    check_irq(1'b0, "post mid-txn reset");

    `uvm_info("SEQ_RESET_MIDTXN", "Sequence #3 completed", UVM_LOW)
  endtask

endclass
