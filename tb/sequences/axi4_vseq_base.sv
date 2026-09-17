// Virtual Sequence Base Class: axi4_vseq_base
// Coordinates write/read sequencers and provides IRQ checking helpers.

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_vseq_base extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(axi4_vseq_base)

  axi4_write_sequencer write_seqr;
  axi4_read_sequencer  read_seqr;
  virtual axi4_if      vif;

  localparam bit [1:0] RESP_OKAY   = 2'b00;
  localparam bit [1:0] RESP_SLVERR = 2'b10;
  localparam bit [1:0] RESP_DECERR = 2'b11;

  function new(string name = "axi4_vseq_base");
    super.new(name);
  endfunction

  virtual task pre_body();
    resolve_handles();
  endtask

  // Resolve sequencer + vif handles from config_db if not assigned by the test
  virtual function void resolve_handles();
    if (write_seqr == null) begin
      if (!uvm_config_db#(axi4_write_sequencer)::get(null, get_full_name(), "write_seqr", write_seqr))
        void'(uvm_config_db#(axi4_write_sequencer)::get(null, "*", "write_seqr", write_seqr));
    end

    if (read_seqr == null) begin
      if (!uvm_config_db#(axi4_read_sequencer)::get(null, get_full_name(), "read_seqr", read_seqr))
        void'(uvm_config_db#(axi4_read_sequencer)::get(null, "*", "read_seqr", read_seqr));
    end

    if (vif == null) begin
      if (!uvm_config_db#(virtual axi4_if)::get(null, get_full_name(), "vif", vif))
        void'(uvm_config_db#(virtual axi4_if)::get(null, "*", "vif", vif));
    end
  endfunction

  virtual task start_write(axi4_write_base_seq wr_seq);
    if (write_seqr == null)
      `uvm_fatal(get_type_name(), "write_seqr is null — set config_db or assign before start")
    wr_seq.start(write_seqr);
  endtask

  virtual task start_read(axi4_read_base_seq rd_seq);
    if (read_seqr == null)
      `uvm_fatal(get_type_name(), "read_seqr is null — set config_db or assign before start")
    rd_seq.start(read_seqr);
  endtask

  // Sample IRQ after a clock edge so DUT combo/registered updates settle
  virtual task check_irq(bit expect_irq, string ctx = "");
    if (vif == null)
      `uvm_fatal(get_type_name(), "vif is null — cannot check IRQ")

    @(posedge vif.ACLK);
    #0;
    if (vif.IRQ !== expect_irq) begin
      `uvm_error(get_type_name(),
        $sformatf("IRQ mismatch%s: got=%0b expect=%0b",
                  (ctx == "") ? "" : {" (", ctx, ")"}, vif.IRQ, expect_irq))
    end else begin
      `uvm_info(get_type_name(),
        $sformatf("IRQ check passed%s: IRQ=%0b",
                  (ctx == "") ? "" : {" (", ctx, ")"}, expect_irq), UVM_MEDIUM)
    end
  endtask

  // Pulse ARESETn for mid-transaction / directed reset tests (F34)
  virtual task pulse_reset(int unsigned hold_cycles = 5);
    if (vif == null)
      `uvm_fatal(get_type_name(), "vif is null — cannot pulse ARESETn")
    @(posedge vif.ACLK);
    vif.ARESETn <= 1'b0;
    repeat (hold_cycles) @(posedge vif.ACLK);
    vif.ARESETn <= 1'b1;
    repeat (2) @(posedge vif.ACLK);
  endtask

endclass
