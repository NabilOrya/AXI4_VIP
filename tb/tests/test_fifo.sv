import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_fifo — sequences 38–42 (F20, F26–F28)
class test_fifo extends axi4_test_base;
  `uvm_component_utils(test_fifo)

  function new(string name = "test_fifo", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_fifo: seqs 38-42 ===", UVM_LOW)

    begin
      seq_fifo_push_pop_basic s; s = seq_fifo_push_pop_basic::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      // Self-clears to empty before pop (must not run only after overflow)
      seq_fifo_underflow_pop_while_empty s;
      s = seq_fifo_underflow_pop_while_empty::type_id::create("s");
      run_vseq(s);
      settle();
    end
    begin
      seq_fifo_overflow_push_while_full s;
      s = seq_fifo_overflow_push_while_full::type_id::create("s");
      run_vseq(s);
      settle();
    end
    begin
      seq_fifo_disable_clears_contents s;
      s = seq_fifo_disable_clears_contents::type_id::create("s");
      run_vseq(s);
      settle();
    end
    begin
      seq_fifo_partial_strobe_reject s;
      s = seq_fifo_partial_strobe_reject::type_id::create("s");
      run_wr(s);
      settle();
    end

    phase.drop_objection(this);
  endtask

endclass
