// Sequence #32: seq_wstrb_sweep_write
// Feature: F4 (WSTRB Byte-Lane Write Strobe Sweep)
// Objective: Sweeps full-strobe, single-byte, and sparse WSTRB patterns to verify per-byte memory update logic.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_wstrb_sweep_write extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(seq_wstrb_sweep_write)

  function new(string name = "seq_wstrb_sweep_write");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_base_seq wr_seq;
    bit [3:0] strb_patterns[4] = '{4'hF, 4'h1, 4'h2, 4'hA}; // Full, byte0, byte1, sparse

    `uvm_info("SEQ_WSTRB_SWEEP_WRITE", "Executing Sequence #32: WSTRB Byte Strobe Sweep", UVM_LOW)

    foreach (strb_patterns[i]) begin
      wr_seq = axi4_write_base_seq::type_id::create($sformatf("wr_strb_%0d", i));
      wr_seq.seq_id       = 4'hA;
      wr_seq.seq_addr     = 16'h0080;
      wr_seq.seq_len      = 8'h00;
      wr_seq.seq_size     = 3'b010;
      wr_seq.seq_burst    = 2'b01;
      wr_seq.fixed_strb   = strb_patterns[i];
      wr_seq.start(m_sequencer);
    end

    `uvm_info("SEQ_WSTRB_SWEEP_WRITE", "Sequence #32 completed", UVM_LOW)
  endtask

endclass
