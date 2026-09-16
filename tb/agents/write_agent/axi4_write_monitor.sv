import uvm_pkg::*;
`include "uvm_macros.svh"

// Passiveive write monitor: reconstruct AW + W beats + B into axi4_write_txn
// and broadcast via analysis port (independent of the driver).
class axi4_write_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_write_monitor)

  virtual axi4_if vif;
  uvm_analysis_port #(axi4_write_txn) item_collected_port;

  // In-order assembly queues (matches DUT issue-order behavior)
  axi4_write_txn aw_pending[$];
  axi4_write_txn w_active;
  axi4_write_txn b_pending[$];

  function new(string name = "axi4_write_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("WRITE_MON", "Virtual interface 'vif' not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.ACLK);

      if (vif.ARESETn !== 1'b1) begin
        flush_state();
        continue;
      end

      collect_aw();
      collect_w();
      collect_b();
    end
  endtask

  function void flush_state();
    aw_pending.delete();
    b_pending.delete();
    w_active = null;
  endfunction

  // Capture accepted write-address requests
  function void collect_aw();
    axi4_write_txn t;

    if (!(vif.AWVALID && vif.AWREADY))
      return;

    t = axi4_write_txn::type_id::create($sformatf("wr_mon_aw_%0t", $time));
    t.id    = vif.AWID;
    t.addr  = vif.AWADDR;
    t.len   = vif.AWLEN;
    t.size  = vif.AWSIZE;
    t.burst = vif.AWBURST;
    t.data  = new[0];
    t.strb  = new[0];
    t.resp  = 2'b00;

    aw_pending.push_back(t);

    `uvm_info("WRITE_MON",
      $sformatf("AW seen: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
                t.id, t.addr, t.len, t.size, t.burst), UVM_HIGH)
  endfunction

  // Capture write-data beats; on WLAST move txn to B-pending queue
  function void collect_w();
    int unsigned beat_idx;
    bit [31:0] data_tmp[];
    bit [3:0]  strb_tmp[];

    if (!(vif.WVALID && vif.WREADY))
      return;

    if (w_active == null) begin
      if (aw_pending.size() == 0) begin
        `uvm_error("WRITE_MON", "W handshake observed with no outstanding AW")
        return;
      end
      w_active = aw_pending.pop_front();
    end

    beat_idx = w_active.data.size();
    data_tmp = new[beat_idx + 1](w_active.data);
    strb_tmp = new[beat_idx + 1](w_active.strb);
    data_tmp[beat_idx] = vif.WDATA;
    strb_tmp[beat_idx] = vif.WSTRB;
    w_active.data = data_tmp;
    w_active.strb = strb_tmp;

    if (vif.WLAST) begin
      if (w_active.data.size() != (int'(w_active.len) + 1)) begin
        `uvm_warning("WRITE_MON",
          $sformatf("WLAST beat-count mismatch: got=%0d expected=%0d (AWLEN=%0d) ID=%0d Addr=0x%0h",
                    w_active.data.size(), int'(w_active.len) + 1,
                    w_active.len, w_active.id, w_active.addr))
      end

      b_pending.push_back(w_active);
      `uvm_info("WRITE_MON",
        $sformatf("W complete: ID=%0d Addr=0x%0h Beats=%0d",
                  w_active.id, w_active.addr, w_active.data.size()), UVM_HIGH)
      w_active = null;
    end
  endfunction

  // Capture B response, complete txn, broadcast
  function void collect_b();
    axi4_write_txn t;

    if (!(vif.BVALID && vif.BREADY))
      return;

    if (b_pending.size() == 0) begin
      `uvm_error("WRITE_MON", "B handshake observed with no completed W burst pending")
      return;
    end

    t = b_pending.pop_front();
    t.resp = vif.BRESP;

    if (vif.BID !== t.id) begin
      `uvm_error("WRITE_MON",
        $sformatf("BID mismatch: bus BID=%0d expected AWID=%0d Addr=0x%0h",
                  vif.BID, t.id, t.addr))
    end

    `uvm_info("WRITE_MON",
      $sformatf("Write txn complete: ID=%0d Addr=0x%0h Beats=%0d BRESP=%0d",
                t.id, t.addr, t.data.size(), t.resp), UVM_MEDIUM)

    item_collected_port.write(t);
  endfunction

endclass
