//verify protocol compliance, signal stability, reset behavior, and IRQ formula

module axi4_sva #(
  parameter int ADDR_W = 16,
  parameter int DATA_W = 32,
  parameter int ID_W   = 4
)(
  input logic ACLK,
  input logic ARESETn,

  input logic [ID_W-1:0]   AWID,
  input logic [ADDR_W-1:0] AWADDR,
  input logic [7:0]        AWLEN,
  input logic [2:0]        AWSIZE,
  input logic [1:0]        AWBURST,
  input logic              AWVALID,
  input logic              AWREADY,

  input logic [DATA_W-1:0]   WDATA,
  input logic [DATA_W/8-1:0] WSTRB,
  input logic                WLAST,
  input logic                WVALID,
  input logic                WREADY,

  input logic [ID_W-1:0] BID,
  input logic [1:0]      BRESP,
  input logic            BVALID,
  input logic            BREADY,

  input logic [ID_W-1:0]   ARID,
  input logic [ADDR_W-1:0] ARADDR,
  input logic [7:0]        ARLEN,
  input logic [2:0]        ARSIZE,
  input logic [1:0]        ARBURST,
  input logic              ARVALID,
  input logic              ARREADY,

  input logic [ID_W-1:0]   RID,
  input logic [DATA_W-1:0] RDATA,
  input logic [1:0]        RRESP,
  input logic              RLAST,
  input logic              RVALID,
  input logic              RREADY,

  input logic IRQ
);

  default clocking cb @(posedge ACLK); endclocking
  default disable iff (!ARESETn);

  // 1. Reset Behavior Assertions 
  property p_reset_deasserts_channels;
    disable iff (1'b0)
    !ARESETn |-> (!AWVALID && !WVALID && !BVALID && !ARVALID && !RVALID);
  endproperty
  a_reset_deasserts_channels: assert property (p_reset_deasserts_channels)
    else $error("[SVA FAIL] Reset active but VALID channel signal asserted!");

  // 2. Handshake Stability Assertions 
  property p_aw_valid_stable;
    AWVALID && !AWREADY |=> AWVALID && $stable({AWID, AWADDR, AWLEN, AWSIZE, AWBURST});
  endproperty
  a_aw_valid_stable: assert property (p_aw_valid_stable)
    else $error("[SVA FAIL] AWVALID or AW payload modified before AWREADY!");

  property p_w_valid_stable;
    WVALID && !WREADY |=> WVALID && $stable({WDATA, WSTRB, WLAST});
  endproperty
  a_w_valid_stable: assert property (p_w_valid_stable)
    else $error("[SVA FAIL] WVALID or W payload modified before WREADY!");

  property p_b_valid_stable;
    BVALID && !BREADY |=> BVALID && $stable({BID, BRESP});
  endproperty
  a_b_valid_stable: assert property (p_b_valid_stable)
    else $error("[SVA FAIL] BVALID or B payload modified before BREADY!");

  property p_ar_valid_stable;
    ARVALID && !ARREADY |=> ARVALID && $stable({ARID, ARADDR, ARLEN, ARSIZE, ARBURST});
  endproperty
  a_ar_valid_stable: assert property (p_ar_valid_stable)
    else $error("[SVA FAIL] ARVALID or AR payload modified before ARREADY!");

  property p_r_valid_stable;
    RVALID && !RREADY |=> RVALID && $stable({RID, RDATA, RRESP, RLAST});
  endproperty
  a_r_valid_stable: assert property (p_r_valid_stable)
    else $error("[SVA FAIL] RVALID or R payload modified before RREADY!");

  // 3. No Unknown (X/Z) Checks (a_no_x_on_active_signals)
  property p_no_x_valid_ready;
    !$isunknown({AWVALID, AWREADY, WVALID, WREADY, BVALID, BREADY, ARVALID, ARREADY, RVALID, RREADY});
  endproperty
  a_no_x_valid_ready: assert property (p_no_x_valid_ready)
    else $error("[SVA FAIL] X or Z detected on VALID/READY signals!");

  property p_no_x_aw_payload;
    AWVALID |-> !$isunknown({AWID, AWADDR, AWLEN, AWSIZE, AWBURST});
  endproperty
  a_no_x_aw_payload: assert property (p_no_x_aw_payload)
    else $error("[SVA FAIL] X or Z detected on active AW channel payload!");

  property p_no_x_w_payload;
    WVALID |-> !$isunknown({WDATA, WSTRB, WLAST});
  endproperty
  a_no_x_w_payload: assert property (p_no_x_w_payload)
    else $error("[SVA FAIL] X or Z detected on active W channel payload!");

  property p_no_x_b_payload;
    BVALID |-> !$isunknown({BID, BRESP});
  endproperty
  a_no_x_b_payload: assert property (p_no_x_b_payload)
    else $error("[SVA FAIL] X or Z detected on active B channel payload!");

  property p_no_x_ar_payload;
    ARVALID |-> !$isunknown({ARID, ARADDR, ARLEN, ARSIZE, ARBURST});
  endproperty
  a_no_x_ar_payload: assert property (p_no_x_ar_payload)
    else $error("[SVA FAIL] X or Z detected on active AR channel payload!");

  property p_no_x_r_payload;
    RVALID |-> !$isunknown({RID, RDATA, RRESP, RLAST});
  endproperty
  a_no_x_r_payload: assert property (p_no_x_r_payload)
    else $error("[SVA FAIL] X or Z detected on active R channel payload!");

  // 4. Protocol Beat Count & Burst End Rules
  // RLAST must be asserted on final beat of read burst
  property p_rlast_must_be_known;
    RVALID |-> !$isunknown(RLAST);
  endproperty
  a_rlast_must_be_known: assert property (p_rlast_must_be_known)
    else $error("[SVA FAIL] RLAST is unknown during active RVALID!");

  // WLAST must be asserted on final beat of write burst
  property p_wlast_must_be_known;
    WVALID |-> !$isunknown(WLAST);
  endproperty
  a_wlast_must_be_known: assert property (p_wlast_must_be_known)
    else $error("[SVA FAIL] WLAST is unknown during active WVALID!");

endmodule
