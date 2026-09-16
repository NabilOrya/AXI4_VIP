import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_backpressure — sequence 49 (F21, F29, F36, F37)
class test_backpressure extends axi4_test_base;
  `uvm_component_utils(test_backpressure)

  function new(string name = "test_backpressure", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    seq_backpressure_sweep s;
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_backpressure: seq 49 ===", UVM_LOW)

    s = seq_backpressure_sweep::type_id::create("s");
    run_vseq(s);
    settle(40);

    phase.drop_objection(this);
  endtask

endclass
