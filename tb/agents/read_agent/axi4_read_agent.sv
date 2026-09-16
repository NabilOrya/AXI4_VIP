import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_read_agent extends uvm_agent;
  `uvm_component_utils(axi4_read_agent)

  axi4_read_driver    driver;
  axi4_read_monitor   monitor;
  axi4_read_sequencer sequencer;

  function new(string name = "axi4_read_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("READ_AGT", "build_phase executed", UVM_LOW)

    monitor = axi4_read_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = axi4_read_driver::type_id::create("driver", this);
      sequencer = axi4_read_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("READ_AGT", "connect_phase executed", UVM_LOW)
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass
