import uvm_pkg::*;
`include "uvm_macros.svh"

// Passiveive read monitor: reconstruct AR + R beats (until RLAST) into axi4_read_txn
// and broadcast via analysis port (independent of the driver).
class axi4_read_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_read_monitor)

  virtual axi4_if vif;
  uvm_analysis_port #(axi4_read_txn) item_collected_port;

  axi4_read_txn ar_pending[$];
  axi4_read_txn r_active;
  int unsigned  r_beat;

  function new(string name = "axi4_read_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("READ_MON", "Virtual interface 'vif' not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.ACLK);

      if (vif.ARESETn !== 1'b1) begin
        flush_state();
        continue;
      end

      collect_ar();
      collect_r();
    end
  endtask

  function void flush_state();
    ar_pending.delete();
    r_active = null;
    r_beat   = 0;
  endfunction

  // Capture accepted read-address requests
  function void collect_ar();
    axi4_read_txn t;

    if (!(vif.ARVALID && vif.ARREADY))
      return;

    t = axi4_read_txn::type_id::create($sformatf("rd_mon_ar_%0t", $time));
    t.id         = vif.ARID;
    t.addr       = vif.ARADDR;
    t.len        = vif.ARLEN;
    t.size       = vif.ARSIZE;
    t.burst      = vif.ARBURST;
    t.data       = new[0];
    t.resp       = new[0];
    t.final_resp = 2'b00;

    ar_pending.push_back(t);

    `uvm_info("READ_MON",
      $sformatf("AR seen: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
                t.id, t.addr, t.len, t.size, t.burst), UVM_HIGH)
  endfunction

  // Capture read-data beats until RLAST, then broadcast
  function void collect_r();
    int unsigned num_beats;
    bit [31:0] data_tmp[];
    bit [1:0]  resp_tmp[];

    if (!(vif.RVALID && vif.RREADY))
      return;

    if (r_active == null) begin
      if (ar_pending.size() == 0) begin
        `uvm_error("READ_MON", "R handshake observed with no outstanding AR")
        return;
      end
      r_active = ar_pending.pop_front();
      r_beat   = 0;

      num_beats = int'(r_active.len) + 1;
      r_active.data = new[num_beats];
      r_active.resp = new[num_beats];
      r_active.final_resp = 2'b00;
    end

    if (r_beat >= r_active.data.size()) begin
      `uvm_error("READ_MON",
        $sformatf("Extra R beat beyond ARLEN+1 (%0d) for ID=%0d Addr=0x%0h",
                  r_active.data.size(), r_active.id, r_active.addr))
      // Grow to avoid out-of-bounds; still flag as error
      data_tmp = new[r_beat + 1](r_active.data);
      resp_tmp = new[r_beat + 1](r_active.resp);
      r_active.data = data_tmp;
      r_active.resp = resp_tmp;
    end

    if (vif.RID !== r_active.id) begin
      `uvm_error("READ_MON",
        $sformatf("RID mismatch: bus RID=%0d expected ARID=%0d Addr=0x%0h",
                  vif.RID, r_active.id, r_active.addr))
    end

    r_active.data[r_beat] = vif.RDATA;
    r_active.resp[r_beat] = vif.RRESP;

    if (vif.RRESP > r_active.final_resp)
      r_active.final_resp = vif.RRESP;

    if (vif.RLAST) begin
      if ((r_beat + 1) != (int'(r_active.len) + 1)) begin
        `uvm_warning("READ_MON",
          $sformatf("RLAST beat-count mismatch: got=%0d expected=%0d (ARLEN=%0d) ID=%0d Addr=0x%0h",
                    r_beat + 1, int'(r_active.len) + 1,
                    r_active.len, r_active.id, r_active.addr))
      end

      `uvm_info("READ_MON",
        $sformatf("Read txn complete: ID=%0d Addr=0x%0h Beats=%0d FinalRESP=%0d RDATA[0]=0x%08h",
                  r_active.id, r_active.addr, r_beat + 1,
                  r_active.final_resp, r_active.data[0]), UVM_MEDIUM)

      item_collected_port.write(r_active);
      r_active = null;
      r_beat   = 0;
    end
    else begin
      r_beat++;
    end
  endfunction

endclass
