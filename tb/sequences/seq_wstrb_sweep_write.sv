// Sequence #32: seq_wstrb_sweep_write
// Feature: F4 (WSTRB Byte-Lane Write Strobe Sweep)
// Objective: Seed RAM, apply strobe patterns, read back. Ref/SB verify byte lanes.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_wstrb_sweep_write extends axi4_vseq_base;
  `uvm_object_utils(seq_wstrb_sweep_write)

  function new(string name = "seq_wstrb_sweep_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    axi4_read_base_seq  rd_seq;
    bit [3:0] strb_patterns[4] = '{4'hF, 4'h1, 4'h2, 4'hA};
    bit [31:0] wr_data[4] = '{32'hA5A5_A5A5, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333};

    `uvm_info("SEQ_WSTRB_SWEEP_WRITE", "Executing Sequence #32: WSTRB Byte Strobe Sweep", UVM_LOW)

    resolve_handles();

    // Seed known background so partial strobes are observable
    wr_seq = axi4_write_base_seq::type_id::create("seed");
    wr_seq.seq_id        = 4'hA;
    wr_seq.seq_addr      = 16'h0080;
    wr_seq.seq_len       = 8'h00;
    wr_seq.seq_size      = 3'b010;
    wr_seq.seq_burst     = 2'b01;
    wr_seq.fixed_strb    = 4'hF;
    wr_seq.override_data = 1;
    wr_seq.seq_data      = new[1];
    wr_seq.seq_data[0]   = 32'hFFFF_FFFF;
    wr_seq.check_resp    = 1;
    wr_seq.expect_resp   = RESP_OKAY;
    start_write(wr_seq);

    foreach (strb_patterns[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("wr_strb_%0d", i));
      wr_seq.seq_id        = 4'hA;
      wr_seq.seq_addr      = 16'h0080;
      wr_seq.seq_len       = 8'h00;
      wr_seq.seq_size      = 3'b010;
      wr_seq.seq_burst     = 2'b01;
      wr_seq.fixed_strb    = strb_patterns[i];
      wr_seq.override_data = 1;
      wr_seq.seq_data      = new[1];
      wr_seq.seq_data[0]   = wr_data[i];
      wr_seq.check_resp    = 1;
      wr_seq.expect_resp   = RESP_OKAY;
      start_write(wr_seq);

      // Readback - scoreboard compares against ref shadow (WSTRB-aware)
      rd_seq = axi4_read_base_seq::type_id::create($sformatf("rd_strb_%0d", i));
      rd_seq.seq_id      = 4'hA;
      rd_seq.seq_addr    = 16'h0080;
      rd_seq.seq_len     = 8'h00;
      rd_seq.seq_size    = 3'b010;
      rd_seq.seq_burst   = 2'b01;
      rd_seq.check_resp  = 1;
      rd_seq.expect_resp = RESP_OKAY;
      start_read(rd_seq);
    end

    `uvm_info("SEQ_WSTRB_SWEEP_WRITE", "Sequence #32 completed", UVM_LOW)
  endtask

endclass
