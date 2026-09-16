import uvm_pkg::*;
`include "uvm_macros.svh"

// Plan §4.10: test_random_regression — randomized mix of sequences 1–50
class test_random_regression extends axi4_test_base;
  `uvm_component_utils(test_random_regression)

  rand int unsigned seed_offset;

  constraint c_seed { seed_offset < 10000; }

  function new(string name = "test_random_regression", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    int unsigned mix[$];
    int unsigned i;
    int unsigned pick;

    phase.raise_objection(this);
    wait_reset_done();

    void'(this.randomize());
    `uvm_info(get_type_name(),
      $sformatf("=== test_random_regression: mix of seqs 1-50 (seed_offset=%0d) ===",
                seed_offset), UVM_LOW)

    // Representative coverage mix across all sequence groups
    mix = '{
      4,  // reg CTRL
      24, // legal FIXED write
      26, // legal INCR write
      33, // RAM region
      34, // REG region
      38, // FIFO push/pop
      43, // IRQ basic
      14, // illegal WRAP write
      35, // unmapped DECERR
      49, // backpressure
      50, // concurrent R/W
      30, // single-beat write
      31, // single-beat read
      8,  // FIFO_DATA access
      48  // outstanding stress
    };

    // Rotate starting point with seed so nightly runs differ
    for (i = 0; i < mix.size(); i++) begin
      pick = mix[(i + seed_offset) % mix.size()];
      run_seq_by_id(pick);
      settle();
    end

    phase.drop_objection(this);
  endtask

  // Dispatch by plan sequence number
  task run_seq_by_id(int unsigned id);
    `uvm_info(get_type_name(), $sformatf("Running sequence #%0d", id), UVM_MEDIUM)
    case (id)
      4:  begin seq_reg_ctrl_rw s; s = seq_reg_ctrl_rw::type_id::create("s"); run_vseq(s); end
      8:  begin seq_reg_fifo_data_access s; s = seq_reg_fifo_data_access::type_id::create("s"); run_vseq(s); end
      14: begin seq_illegal_wrap_burst_write s; s = seq_illegal_wrap_burst_write::type_id::create("s"); run_wr(s); end
      24: begin seq_legal_fixed_burst_write s; s = seq_legal_fixed_burst_write::type_id::create("s"); run_wr(s); end
      26: begin seq_legal_incr_burst_write s; s = seq_legal_incr_burst_write::type_id::create("s"); run_wr(s); end
      30: begin seq_single_beat_write s; s = seq_single_beat_write::type_id::create("s"); run_wr(s); end
      31: begin seq_single_beat_read s; s = seq_single_beat_read::type_id::create("s"); run_rd(s); end
      33: begin seq_addr_ram_region_rw s; s = seq_addr_ram_region_rw::type_id::create("s"); run_vseq(s); end
      34: begin seq_addr_reg_region_rw s; s = seq_addr_reg_region_rw::type_id::create("s"); run_vseq(s); end
      35: begin seq_addr_unmapped_decerr s; s = seq_addr_unmapped_decerr::type_id::create("s"); run_vseq(s); end
      38: begin seq_fifo_push_pop_basic s; s = seq_fifo_push_pop_basic::type_id::create("s"); run_vseq(s); end
      43: begin seq_irq_basic_assert_deassert s; s = seq_irq_basic_assert_deassert::type_id::create("s"); run_vseq(s); end
      48: begin seq_outstanding_depth_stress s; s = seq_outstanding_depth_stress::type_id::create("s"); run_wr(s); end
      49: begin seq_backpressure_sweep s; s = seq_backpressure_sweep::type_id::create("s"); run_vseq(s); end
      50: begin seq_concurrent_read_write s; s = seq_concurrent_read_write::type_id::create("s"); run_vseq(s); end
      default: `uvm_warning(get_type_name(), $sformatf("No dispatcher for seq #%0d — skipped", id))
    endcase
  endtask

endclass
