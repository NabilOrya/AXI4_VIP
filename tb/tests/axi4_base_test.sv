import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_base_test extends uvm_test;
  `uvm_component_utils(axi4_base_test)

  axi4_env env;

  function new(string name = "axi4_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BASE_TEST", "build_phase executed", UVM_LOW)
    env = axi4_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("BASE_TEST", "Printing UVM Topology:", UVM_LOW)
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("SANITY_TEST", "--- SKELETON TEST RUNNING SUCCESSFULLY ---", UVM_LOW)
    #100;
    phase.drop_objection(this);
  endtask

endclass
