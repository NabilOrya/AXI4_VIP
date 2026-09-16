import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_irq — sequences 43–47 (F19, F22–F25)
class test_irq extends axi4_test_base;
  `uvm_component_utils(test_irq)

  function new(string name = "test_irq", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_irq: seqs 43-47 ===", UVM_LOW)

    begin
      seq_irq_basic_assert_deassert s;
      s = seq_irq_basic_assert_deassert::type_id::create("s");
      run_vseq(s);
      settle();
    end
    begin
      seq_irq_mask_sweep s; s = seq_irq_mask_sweep::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_irq_en_gate s; s = seq_irq_en_gate::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_irq_w1c_clear s; s = seq_irq_w1c_clear::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_irq_level_set_fifo_flags s;
      s = seq_irq_level_set_fifo_flags::type_id::create("s");
      run_vseq(s);
      settle();
    end

    phase.drop_objection(this);
  endtask

endclass
