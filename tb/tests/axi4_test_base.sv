import uvm_pkg::*;
`include "uvm_macros.svh"

// Shared test infrastructure for all plan §4.10 tests
class axi4_test_base extends uvm_test;
  `uvm_component_utils(axi4_test_base)

  axi4_env env;
  virtual axi4_if vif;

  function new(string name = "axi4_test_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      void'(uvm_config_db#(virtual axi4_if)::get(null, "*", "vif", vif));
  endfunction

  // Wait for DUT reset release
  virtual task wait_reset_done();
    if (vif != null) begin
      wait (vif.ARESETn === 1'b1);
      repeat (2) @(posedge vif.ACLK);
    end
    else
      #50;
  endtask

  // Allow monitor → ref → SB to drain
  virtual task settle(int unsigned cycles = 5);
    if (vif != null)
      repeat (cycles) @(posedge vif.ACLK);
    else
      #(cycles * 10);
  endtask

  // Virtual / mixed R+W sequences (axi4_vseq_base)
  virtual task run_vseq(axi4_vseq_base seq);
    seq.start(null);
  endtask

  // Write-only sequences
  virtual task run_wr(uvm_sequence_base seq);
    if (env.write_agent.sequencer == null)
      `uvm_fatal(get_type_name(), "write_agent.sequencer is null")
    seq.start(env.write_agent.sequencer);
  endtask

  // Read-only sequences
  virtual task run_rd(uvm_sequence_base seq);
    if (env.read_agent.sequencer == null)
      `uvm_fatal(get_type_name(), "read_agent.sequencer is null")
    seq.start(env.read_agent.sequencer);
  endtask

  // Generic sequence on null sequencer (e.g. seq_reset_basic)
  virtual task run_null_seq(uvm_sequence_base seq);
    seq.start(null);
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server rs;
    int n_err, n_fatal;
    super.report_phase(phase);
    rs = uvm_report_server::get_server();
    n_err   = rs.get_severity_count(UVM_ERROR);
    n_fatal = rs.get_severity_count(UVM_FATAL);
    if ((n_err == 0) && (n_fatal == 0))
      `uvm_info(get_type_name(), $sformatf("*** %s PASSED ***", get_type_name()), UVM_NONE)
    else
      `uvm_error(get_type_name(),
        $sformatf("*** %s FAILED *** errors=%0d fatals=%0d",
                  get_type_name(), n_err, n_fatal))
  endfunction

endclass
