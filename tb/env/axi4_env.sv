import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_env extends uvm_env;
  `uvm_component_utils(axi4_env)

  axi4_write_agent write_agent;
  axi4_read_agent  read_agent;
  axi4_ref_model   ref_model;
  axi4_scoreboard  scoreboard;
  axi4_coverage    coverage;

  function new(string name = "axi4_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV", "build_phase executed", UVM_LOW)

    write_agent = axi4_write_agent::type_id::create("write_agent", this);
    read_agent  = axi4_read_agent::type_id::create("read_agent", this);
    ref_model   = axi4_ref_model::type_id::create("ref_model", this);
    scoreboard  = axi4_scoreboard::type_id::create("scoreboard", this);
    coverage    = axi4_coverage::type_id::create("coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "connect_phase executed", UVM_LOW)

    // Monitor -> ref first so expectations are queued before/with actuals
    write_agent.monitor.item_collected_port.connect(ref_model.write_export);
    read_agent.monitor.item_collected_port.connect(ref_model.read_export);

    // Monitor -> scoreboard (actuals)
    write_agent.monitor.item_collected_port.connect(scoreboard.write_export);
    read_agent.monitor.item_collected_port.connect(scoreboard.read_export);

    // Ref predictions -> scoreboard
    ref_model.exp_write_port.connect(scoreboard.exp_write_export);
    ref_model.exp_read_port.connect(scoreboard.exp_read_export);
    scoreboard.ref_model = ref_model;

    // Coverage
    write_agent.monitor.item_collected_port.connect(coverage.write_export);
    read_agent.monitor.item_collected_port.connect(coverage.read_export);

    // Needed by virtual / mixed R+W sequences (axi4_vseq_base)
    if (write_agent.sequencer != null)
      uvm_config_db#(axi4_write_sequencer)::set(null, "*", "write_seqr", write_agent.sequencer);
    if (read_agent.sequencer != null)
      uvm_config_db#(axi4_read_sequencer)::set(null, "*", "read_seqr", read_agent.sequencer);
  endfunction

endclass
