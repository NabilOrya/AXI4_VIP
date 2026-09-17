import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_directed_burst_basic — sequences 24–32
class test_directed_burst_basic extends axi4_test_base;
  `uvm_component_utils(test_directed_burst_basic)

  function new(string name = "test_directed_burst_basic", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_directed_burst_basic: seqs 24-32 ===", UVM_LOW)

    begin
      seq_legal_fixed_burst_write s; s = seq_legal_fixed_burst_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_legal_fixed_burst_read s; s = seq_legal_fixed_burst_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_legal_incr_burst_write s; s = seq_legal_incr_burst_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_legal_incr_burst_read s; s = seq_legal_incr_burst_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_max_length_burst_write s; s = seq_max_length_burst_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_max_length_burst_read s; s = seq_max_length_burst_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_single_beat_write s; s = seq_single_beat_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_single_beat_read s; s = seq_single_beat_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_wstrb_sweep_write s; s = seq_wstrb_sweep_write::type_id::create("s"); run_vseq(s); settle();
    end

    phase.drop_objection(this);
  endtask

endclass
