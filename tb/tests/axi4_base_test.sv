import uvm_pkg::*;
`include "uvm_macros.svh"

// Phase-1 smoke (not in §4.10 list): CTRL write/readback pipe check
class axi4_base_test extends axi4_test_base;
  `uvm_component_utils(axi4_base_test)

  function new(string name = "axi4_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    seq_reg_ctrl_rw smoke_seq;
    phase.raise_objection(this);
    wait_reset_done();

    `uvm_info(get_type_name(), "=== Smoke: seq_reg_ctrl_rw ===", UVM_LOW)
    smoke_seq = seq_reg_ctrl_rw::type_id::create("smoke_seq");
    run_vseq(smoke_seq);
    settle();

    phase.drop_objection(this);
  endtask

endclass
