import uvm_pkg::*;
`include "uvm_macros.svh"

// Phase 1 read driver: sequential AR -> collect R beats until RLAST.
// Programmable RREADY backpressure comes later (F37).
class axi4_read_driver extends uvm_driver #(axi4_read_txn);
  `uvm_component_utils(axi4_read_driver)

  virtual axi4_if vif;

  function new(string name = "axi4_read_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("READ_DRV", "Virtual interface 'vif' not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    reset_signals();

    forever begin
      seq_item_port.get_next_item(req);

      // Level-sensitive: also covers "already in reset" (negedge alone can miss that)
      if (vif.ARESETn !== 1'b1) begin
        `uvm_info("READ_DRV", "Waiting for ARESETn before driving read", UVM_MEDIUM)
        wait (vif.ARESETn === 1'b1);
      end

      // Sync to clock before first drive edge
      @(posedge vif.ACLK);
      vif.RREADY <= 1'b1;

      `uvm_info("READ_DRV",
        $sformatf("Driving read: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
                  req.id, req.addr, req.len, req.size, req.burst), UVM_MEDIUM)

      fork
        begin
          drive_read_txn(req);
        end
        begin
          // Abort if reset asserts (or is already low)
          wait (vif.ARESETn !== 1'b1);
          reset_signals();
        end
      join_any
      disable fork;

      // Always complete the sequencer handshake (even if reset aborted the drive)
      idle_read_channels();
      seq_item_port.item_done();
    end
  endtask

  // Drive all master-owned read-side pins to a known idle state
  task reset_signals();
    vif.ARID    <= '0;
    vif.ARADDR  <= '0;
    vif.ARLEN   <= '0;
    vif.ARSIZE  <= '0;
    vif.ARBURST <= '0;
    vif.ARVALID <= 1'b0;

    vif.RREADY  <= 1'b0;
  endtask

  // After a completed (or aborted) item, leave ARVALID low; keep RREADY if out of reset
  task idle_read_channels();
    vif.ARVALID <= 1'b0;
    if (vif.ARESETn === 1'b1)
      vif.RREADY <= 1'b1;
    else
      vif.RREADY <= 1'b0;
  endtask

  task drive_read_txn(axi4_read_txn txn);
    int unsigned num_beats;
    int unsigned beat;
    bit got_last;

    num_beats = int'(txn.len) + 1;
    txn.data = new[num_beats];
    txn.resp = new[num_beats];
    txn.final_resp = 2'b00;

    if (vif.ARESETn !== 1'b1)
      return;

    // ----- AR channel -----
    vif.ARID    <= txn.id;
    vif.ARADDR  <= txn.addr;
    vif.ARLEN   <= txn.len;
    vif.ARSIZE  <= txn.size;
    vif.ARBURST <= txn.burst;
    vif.ARVALID <= 1'b1;

    while (1) begin
      @(posedge vif.ACLK);
      if (vif.ARESETn !== 1'b1)
        return;
      if (vif.ARVALID && vif.ARREADY)
        break;
    end

    vif.ARVALID <= 1'b0;

    // ----- R channel -----
    beat = 0;
    got_last = 1'b0;

    while (!got_last) begin
      if (vif.ARESETn !== 1'b1)
        return;

      while (1) begin
        @(posedge vif.ACLK);
        if (vif.ARESETn !== 1'b1)
          return;
        if (vif.RVALID && vif.RREADY)
          break;
      end

      if (beat >= num_beats)
        `uvm_fatal("READ_DRV",
          $sformatf("Received beat %0d but expected only %0d beats (ARLEN=%0d)",
                    beat, num_beats, txn.len))

      // Sample before DUT NBA advances rd_beat / pops response state
      txn.data[beat] = vif.RDATA;
      txn.resp[beat] = vif.RRESP;

      // Worst-case resp across beats (OKAY=0 < SLVERR=2 < DECERR=3)
      if (vif.RRESP > txn.final_resp)
        txn.final_resp = vif.RRESP;

      got_last = vif.RLAST;
      beat++;
    end

    if (beat != num_beats)
      `uvm_error("READ_DRV",
        $sformatf("RLAST seen after %0d beats, expected %0d (ARLEN=%0d)",
                  beat, num_beats, txn.len))

    `uvm_info("READ_DRV",
      $sformatf("Read complete: ID=%0d Addr=0x%0h Beats=%0d FinalRESP=%0d RDATA[0]=0x%08h",
                txn.id, txn.addr, beat, txn.final_resp, txn.data[0]), UVM_MEDIUM)
  endtask

endclass
