import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_concurrent_rw — sequence 50 (F31)
class test_concurrent_rw extends axi4_test_base;
  `uvm_component_utils(test_concurrent_rw)

  function new(string name = "test_concurrent_rw", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    seq_concurrent_read_write s;
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_concurrent_rw: seq 50 ===", UVM_LOW)

    s = seq_concurrent_read_write::type_id::create("s");
    run_vseq(s);
    settle(20);

    phase.drop_objection(this);
  endtask

endclass
