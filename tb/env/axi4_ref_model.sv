import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_ref_model extends uvm_component;
  `uvm_component_utils(axi4_ref_model)

  function new(string name = "axi4_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("REF_MODEL", "build_phase executed", UVM_LOW)
  endfunction

endclass
