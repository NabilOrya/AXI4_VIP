import uvm_pkg::*;
`include "uvm_macros.svh"

// Phase 1 write driver: sequential AW -> W beats -> B response.
// Outstanding AW/W overlap and programmable BREADY policy come later (F2/F3/F37).
class axi4_write_driver extends uvm_driver #(axi4_write_txn);
  `uvm_component_utils(axi4_write_driver)

  virtual axi4_if vif;

  function new(string name = "axi4_write_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("WRITE_DRV", "Virtual interface 'vif' not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    reset_signals();

    forever begin
      seq_item_port.get_next_item(req);

      // Level-sensitive: also covers "already in reset" (negedge alone can miss that)
      if (vif.ARESETn !== 1'b1) begin
        `uvm_info("WRITE_DRV", "Waiting for ARESETn before driving write", UVM_MEDIUM)
        wait (vif.ARESETn === 1'b1);
      end

      // Sync to clock before first drive edge
      @(posedge vif.ACLK);
      vif.BREADY <= 1'b1;

      `uvm_info("WRITE_DRV",
        $sformatf("Driving write: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
                  req.id, req.addr, req.len, req.size, req.burst), UVM_MEDIUM)

      fork
        begin
          drive_write_txn(req);
        end
        begin
          // Abort if reset asserts (or is already low)
          wait (vif.ARESETn !== 1'b1);
          reset_signals();
        end
      join_any
      disable fork;

      // Always complete the sequencer handshake (even if reset aborted the drive)
      idle_write_channels();
      seq_item_port.item_done();
    end
  endtask

  // Drive all master-owned write-side pins to a known idle state
  task reset_signals();
    vif.AWID    <= '0;
    vif.AWADDR  <= '0;
    vif.AWLEN   <= '0;
    vif.AWSIZE  <= '0;
    vif.AWBURST <= '0;
    vif.AWVALID <= 1'b0;

    vif.WDATA   <= '0;
    vif.WSTRB   <= '0;
    vif.WLAST   <= 1'b0;
    vif.WVALID  <= 1'b0;

    vif.BREADY  <= 1'b0;
  endtask

  // After a completed (or aborted) item, leave valids low; keep BREADY if out of reset
  task idle_write_channels();
    vif.AWVALID <= 1'b0;
    vif.WVALID  <= 1'b0;
    vif.WLAST   <= 1'b0;
    if (vif.ARESETn === 1'b1)
      vif.BREADY <= 1'b1;
    else
      vif.BREADY <= 1'b0;
  endtask

  task drive_write_txn(axi4_write_txn txn);
    int unsigned num_beats;
    int unsigned i;

    num_beats = int'(txn.len) + 1;

    if (txn.data.size() < num_beats)
      `uvm_fatal("WRITE_DRV",
        $sformatf("data.size()=%0d < expected beats=%0d", txn.data.size(), num_beats))
    if (txn.strb.size() < num_beats)
      `uvm_fatal("WRITE_DRV",
        $sformatf("strb.size()=%0d < expected beats=%0d", txn.strb.size(), num_beats))

    if (vif.ARESETn !== 1'b1)
      return;

    // ----- AW channel -----
    vif.AWID    <= txn.id;
    vif.AWADDR  <= txn.addr;
    vif.AWLEN   <= txn.len;
    vif.AWSIZE  <= txn.size;
    vif.AWBURST <= txn.burst;
    vif.AWVALID <= 1'b1;

    // Wait for AW handshake (VALID already high from previous NBA or same cycle schedule)
    while (1) begin
      @(posedge vif.ACLK);
      if (vif.ARESETn !== 1'b1)
        return;
      if (vif.AWVALID && vif.AWREADY)
        break;
    end

    vif.AWVALID <= 1'b0;

    // ----- W channel -----
    for (i = 0; i < num_beats; i++) begin
      if (vif.ARESETn !== 1'b1)
        return;

      vif.WDATA  <= txn.data[i];
      vif.WSTRB  <= txn.strb[i];
      vif.WLAST  <= (i == (num_beats - 1));
      vif.WVALID <= 1'b1;

      while (1) begin
        @(posedge vif.ACLK);
        if (vif.ARESETn !== 1'b1)
          return;
        if (vif.WVALID && vif.WREADY)
          break;
      end
    end

    vif.WVALID <= 1'b0;
    vif.WLAST  <= 1'b0;

    // ----- B channel (BREADY held high by run_phase / idle) -----
    while (1) begin
      @(posedge vif.ACLK);
      if (vif.ARESETn !== 1'b1)
        return;
      if (vif.BVALID && vif.BREADY)
        break;
    end

    // Sample while BRESP still reflects the accepted response (before NBA pops the queue)
    txn.resp = vif.BRESP;

    `uvm_info("WRITE_DRV",
      $sformatf("Write complete: ID=%0d Addr=0x%0h BRESP=%0d",
                txn.id, txn.addr, txn.resp), UVM_MEDIUM)
  endtask

endclass
