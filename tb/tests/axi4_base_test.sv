import uvm_pkg::*;
`include "uvm_macros.svh"

// Phase-1 smoke test: prove driver → DUT → monitor → ref → scoreboard pipe
// using a simple CTRL write + readback (seq_reg_ctrl_rw).
class axi4_base_test extends uvm_test;
  `uvm_component_utils(axi4_base_test)

  axi4_env env;

  function new(string name = "axi4_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BASE_TEST", "build_phase executed", UVM_LOW)
    env = axi4_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("BASE_TEST", "Printing UVM Topology:", UVM_LOW)
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    seq_reg_ctrl_rw smoke_seq;
    virtual axi4_if vif;

    phase.raise_objection(this);

    // Wait until reset is released (top holds ARESETn low for 20ns)
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      void'(uvm_config_db#(virtual axi4_if)::get(null, "*", "vif", vif));

    if (vif != null) begin
      wait (vif.ARESETn === 1'b1);
      repeat (2) @(posedge vif.ACLK);
    end
    else begin
      #50;
    end

    `uvm_info("SMOKE_TEST", "=== Phase-1 smoke: starting seq_reg_ctrl_rw ===", UVM_LOW)

    smoke_seq = seq_reg_ctrl_rw::type_id::create("smoke_seq");
    // Virtual sequence: sequencers resolved via config_db from env.connect_phase
    smoke_seq.start(null);

    // Allow last B/R → monitor → SB to settle
    if (vif != null)
      repeat (5) @(posedge vif.ACLK);
    else
      #50;

    `uvm_info("SMOKE_TEST", "=== Phase-1 smoke sequence completed ===", UVM_LOW)

    phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server rs;
    int n_err, n_fatal;
    super.report_phase(phase);
    rs = uvm_report_server::get_server();
    n_err   = rs.get_severity_count(UVM_ERROR);
    n_fatal = rs.get_severity_count(UVM_FATAL);
    if ((n_err == 0) && (n_fatal == 0))
      `uvm_info("SMOKE_TEST", "*** PHASE-1 SMOKE PASSED ***", UVM_NONE)
    else
      `uvm_error("SMOKE_TEST",
        $sformatf("*** PHASE-1 SMOKE FAILED *** errors=%0d fatals=%0d", n_err, n_fatal))
  endfunction

endclass
