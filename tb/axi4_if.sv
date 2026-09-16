interface axi4_if #(parameter ADDR_W=16, DATA_W=32, ID_W=4) (input logic ACLK);

  logic ARESETn;
  logic IRQ; //Added this missing Signal

  logic [ID_W-1:0]   AWID;
  logic [ADDR_W-1:0] AWADDR;
  logic [7:0]        AWLEN;
  logic [2:0]        AWSIZE;
  logic [1:0]        AWBURST;
  logic              AWVALID;
  logic              AWREADY;

  logic [DATA_W-1:0]   WDATA;
  logic [DATA_W/8-1:0] WSTRB;
  logic                WLAST;
  logic                WVALID;
  logic                WREADY;

  logic [ID_W-1:0] BID;
  logic [1:0]      BRESP;
  logic            BVALID;
  logic            BREADY;

  logic [ID_W-1:0]   ARID;
  logic [ADDR_W-1:0] ARADDR;
  logic [7:0]        ARLEN;
  logic [2:0]        ARSIZE;
  logic [1:0]        ARBURST;
  logic              ARVALID;
  logic              ARREADY;

  logic [ID_W-1:0]   RID;
  logic [DATA_W-1:0] RDATA;
  logic [1:0]        RRESP;
  logic              RLAST;
  logic              RVALID;
  logic              RREADY;

endinterface
