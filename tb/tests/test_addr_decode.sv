import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_addr_decode — sequences 33–37 (F14–F17)
class test_addr_decode extends axi4_test_base;
  `uvm_component_utils(test_addr_decode)

  function new(string name = "test_addr_decode", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_addr_decode: seqs 33-37 ===", UVM_LOW)

    begin
      seq_addr_ram_region_rw s; s = seq_addr_ram_region_rw::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_addr_reg_region_rw s; s = seq_addr_reg_region_rw::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_addr_unmapped_decerr s; s = seq_addr_unmapped_decerr::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_addr_error_window_slverr s; s = seq_addr_error_window_slverr::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_addr_reg_gap_decerr s; s = seq_addr_reg_gap_decerr::type_id::create("s"); run_vseq(s); settle();
    end

    phase.drop_objection(this);
  endtask

endclass
