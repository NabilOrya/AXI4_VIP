import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi4_scoreboard)

  uvm_analysis_imp_write #(axi4_write_txn, axi4_scoreboard) write_export;
  uvm_analysis_imp_read  #(axi4_read_txn,  axi4_scoreboard) read_export;

  function new(string name = "axi4_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    write_export = new("write_export", this);
    read_export  = new("read_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD", "build_phase executed", UVM_LOW)
  endfunction

  function void write_write(axi4_write_txn t);
    `uvm_info("SCOREBOARD", $sformatf("Received Write Txn: ID=%0d Addr=0x%0h", t.id, t.addr), UVM_HIGH)
  endfunction

  function void write_read(axi4_read_txn t);
    `uvm_info("SCOREBOARD", $sformatf("Received Read Txn: ID=%0d Addr=0x%0h", t.id, t.addr), UVM_HIGH)
  endfunction

endclass
