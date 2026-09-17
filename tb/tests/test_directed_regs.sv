import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_directed_regs — sequences 4–13
class test_directed_regs extends axi4_test_base;
  `uvm_component_utils(test_directed_regs)

  function new(string name = "test_directed_regs", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait_reset_done();
    `uvm_info(get_type_name(), "=== test_directed_regs: seqs 4-13 ===", UVM_LOW)

    begin
      seq_reg_ctrl_rw s; s = seq_reg_ctrl_rw::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_status_ro_check s; s = seq_reg_status_ro_check::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_int_en_rw s; s = seq_reg_int_en_rw::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_int_status_w1c s; s = seq_reg_int_status_w1c::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_fifo_data_access s; s = seq_reg_fifo_data_access::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_fifo_status_ro_check s; s = seq_reg_fifo_status_ro_check::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_delay_cfg_rw s; s = seq_reg_delay_cfg_rw::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_txn_count_ro_check s; s = seq_reg_txn_count_ro_check::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      seq_reg_bit_bash_all s; s = seq_reg_bit_bash_all::type_id::create("s"); run_vseq(s); settle();
    end
    begin
      // vseq: pulses ARESETn then readbacks (ref/SB check reset defaults)
      seq_reg_hw_reset_check s; s = seq_reg_hw_reset_check::type_id::create("s"); run_vseq(s); settle();
    end

    phase.drop_objection(this);
  endtask

endclass
