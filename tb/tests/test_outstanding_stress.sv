import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_outstanding_stress — sequence 48 (F2, F3, F32, F33)
class test_outstanding_stress extends axi4_test_base;
  `uvm_component_utils(test_outstanding_stress)

  function new(string name = "test_outstanding_stress", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    seq_outstanding_depth_stress s;
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_outstanding_stress: seq 48 ===", UVM_LOW)

    s = seq_outstanding_depth_stress::type_id::create("s");
    run_wr(s);
    settle(30);

    phase.drop_objection(this);
  endtask

endclass
