import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_reset — sequences 1–3 (F1, F34)
class test_reset extends axi4_test_base;
  `uvm_component_utils(test_reset)

  function new(string name = "test_reset", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    seq_reset_basic        s1;
    seq_reset_readback_zero s2;
    seq_reset_midtxn       s3;

    phase.raise_objection(this);
    wait_reset_done();

    `uvm_info(get_type_name(), "=== test_reset: seqs 1-3 ===", UVM_LOW)

    s1 = seq_reset_basic::type_id::create("s1");
    run_null_seq(s1);
    settle();

    s2 = seq_reset_readback_zero::type_id::create("s2");
    run_rd(s2);
    settle();

    s3 = seq_reset_midtxn::type_id::create("s3");
    run_vseq(s3); // needs write+read sequencers + vif for ARESETn
    settle();

    phase.drop_objection(this);
  endtask

endclass
