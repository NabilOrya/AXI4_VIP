import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_negative_burst — sequences 14–23 (F10–F13)
class test_negative_burst extends axi4_test_base;
  `uvm_component_utils(test_negative_burst)

  function new(string name = "test_negative_burst", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_negative_burst: seqs 14-23 ===", UVM_LOW)

    begin
      seq_illegal_wrap_burst_write s; s = seq_illegal_wrap_burst_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_illegal_wrap_burst_read s; s = seq_illegal_wrap_burst_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_illegal_reserved_burst_write s; s = seq_illegal_reserved_burst_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_illegal_reserved_burst_read s; s = seq_illegal_reserved_burst_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_illegal_len_gt15_write s; s = seq_illegal_len_gt15_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_illegal_len_gt15_read s; s = seq_illegal_len_gt15_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_illegal_size_gt2_write s; s = seq_illegal_size_gt2_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_illegal_size_gt2_read s; s = seq_illegal_size_gt2_read::type_id::create("s"); run_rd(s); settle();
    end
    begin
      seq_illegal_4k_boundary_write s; s = seq_illegal_4k_boundary_write::type_id::create("s"); run_wr(s); settle();
    end
    begin
      seq_illegal_4k_boundary_read s; s = seq_illegal_4k_boundary_read::type_id::create("s"); run_rd(s); settle();
    end

    phase.drop_objection(this);
  endtask

endclass
