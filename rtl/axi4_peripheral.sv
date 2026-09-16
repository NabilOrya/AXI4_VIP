module axi4_peripheral #(
  parameter int ADDR_W=16,
  parameter int DATA_W=32,
  parameter int ID_W=4,
  parameter int QDEPTH=4
)(
  input logic ACLK,
  input logic ARESETn,

  input  logic [ID_W-1:0]   AWID,
  input  logic [ADDR_W-1:0] AWADDR,
  input  logic [7:0]        AWLEN,
  input  logic [2:0]        AWSIZE,
  input  logic [1:0]        AWBURST,
  input  logic              AWVALID,
  output logic              AWREADY,

  input  logic [DATA_W-1:0]   WDATA,
  input  logic [DATA_W/8-1:0] WSTRB,
  input  logic                WLAST,
  input  logic                WVALID,
  output logic                WREADY,

  output logic [ID_W-1:0] BID,
  output logic [1:0]      BRESP,
  output logic            BVALID,
  input  logic            BREADY,

  input  logic [ID_W-1:0]   ARID,
  input  logic [ADDR_W-1:0] ARADDR,
  input  logic [7:0]        ARLEN,
  input  logic [2:0]        ARSIZE,
  input  logic [1:0]        ARBURST,
  input  logic              ARVALID,
  output logic              ARREADY,

  output logic [ID_W-1:0]   RID,
  output logic [DATA_W-1:0] RDATA,
  output logic [1:0]        RRESP,
  output logic              RLAST,
  output logic              RVALID,
  input  logic              RREADY,

  output logic IRQ
);

  localparam logic [1:0] OKAY   = 2'b00;
  localparam logic [1:0] SLVERR = 2'b10;
  localparam logic [1:0] DECERR = 2'b11;

  localparam logic [15:0] A_CTRL       = 16'h1000;
  localparam logic [15:0] A_STATUS     = 16'h1004;
  localparam logic [15:0] A_INT_EN     = 16'h1008;
  localparam logic [15:0] A_INT_STATUS = 16'h100C;
  localparam logic [15:0] A_FIFO_DATA  = 16'h1010;
  localparam logic [15:0] A_FIFO_STAT  = 16'h1014;
  localparam logic [15:0] A_DELAY_CFG  = 16'h1018;
  localparam logic [15:0] A_TXN_COUNT  = 16'h101C;

  typedef struct packed {
    logic [ID_W-1:0] id;
    logic [15:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
  } req_t;

  typedef struct packed {
    logic [ID_W-1:0] id;
    logic [1:0] resp;
  } b_t;

  req_t aw_q[0:QDEPTH-1];
  req_t ar_q[0:QDEPTH-1];
  b_t b_q[0:QDEPTH-1];

  integer aw_head,aw_tail,aw_count;
  integer ar_head,ar_tail,ar_count;
  integer b_head,b_tail,b_count;

  logic [7:0] ram[0:4095];

  logic [2:0] ctrl;
  logic [2:0] int_en;
  logic [2:0] int_status;
  logic [7:0] delay_cfg;
  logic [31:0] txn_count;

  logic fifo_push,fifo_pop;
  logic [31:0] fifo_rdata;
  logic fifo_empty,fifo_full;
  logic [4:0] fifo_level;

  logic wr_active;
  req_t wr_req;
  logic [7:0] wr_beat;
  logic [1:0] wr_resp_accum;

  logic rd_active;
  req_t rd_req;
  logic [7:0] rd_beat;

  logic [3:0] aw_wait,w_wait,ar_wait,r_wait,b_wait;
  logic [15:0] lfsr;

  assign IRQ = ctrl[0] && (|(int_en & int_status));

  axi_fifo #(.WIDTH(32),.DEPTH(16)) u_fifo(
    .clk(ACLK),
    .rst_n(ARESETn),
    .clear(!ctrl[1]),
    .push(fifo_push),
    .pop(fifo_pop),
    .wdata(WDATA),
    .rdata(fifo_rdata),
    .empty(fifo_empty),
    .full(fifo_full),
    .level(fifo_level)
  );

  function automatic logic [15:0] beat_addr(
    input logic [15:0] base,
    input logic [7:0] beat,
    input logic [2:0] size,
    input logic [1:0] burst
  );
    if(burst==2'b00)
      return base;

    return base + (beat << size);
  endfunction

  function automatic logic is_ram(input logic [15:0] a);
    return a <= 16'h0FFF;
  endfunction

  function automatic logic is_reg(input logic [15:0] a);
    return a inside {
      A_CTRL,A_STATUS,A_INT_EN,A_INT_STATUS,
      A_FIFO_DATA,A_FIFO_STAT,A_DELAY_CFG,A_TXN_COUNT
    };
  endfunction

  function automatic logic [1:0] address_resp(input logic [15:0] a);
    if((a>=16'h2000)&&(a<=16'h2FFF))
      return SLVERR;

    if(is_ram(a)||is_reg(a))
      return OKAY;

    return DECERR;
  endfunction

  function automatic logic illegal_burst(
    input logic [15:0] a,
    input logic [7:0] len,
    input logic [2:0] size,
    input logic [1:0] burst
  );
    logic [16:0] last_a;

    if(len>15)
      return 1'b1;

    if(size>2)
      return 1'b1;

    if(!(burst inside {2'b00,2'b01}))
      return 1'b1;

    last_a=a+(len<<size);

    if((burst==2'b01)&&(a[15:12]!=last_a[15:12]))
      return 1'b1;

    return 1'b0;
  endfunction

  function automatic logic [31:0] read_mem(input logic [15:0] a);
    logic [31:0] v;
    v='0;

    for(int i=0;i<4;i++)
      if((a+i)<=16'h0FFF)
        v[i*8 +:8]=ram[a+i];

    return v;
  endfunction

  function automatic logic [31:0] read_reg(input logic [15:0] a);
    case(a)
      A_CTRL:       return {29'h0,ctrl};
      A_STATUS:     return {27'h0,IRQ,fifo_full,fifo_empty,(ar_count!=0)||(rd_active),(aw_count!=0)||(wr_active)};
      A_INT_EN:     return {29'h0,int_en};
      A_INT_STATUS: return {29'h0,int_status};
      A_FIFO_DATA:  return fifo_rdata;
      A_FIFO_STAT:  return {23'h0,fifo_level,2'b0,fifo_full,fifo_empty};
      A_DELAY_CFG:  return {24'h0,delay_cfg};
      A_TXN_COUNT:  return txn_count;
      default:      return '0;
    endcase
  endfunction

  function automatic logic [3:0] make_delay(input logic read_side);
    logic [3:0] maxd;

    if(!ctrl[2])
      return 0;

    maxd=read_side?delay_cfg[7:4]:delay_cfg[3:0];

    if(maxd==0)
      return 0;

    return lfsr[3:0]%(maxd+1);
  endfunction

  always_comb begin
    AWREADY=(aw_count<QDEPTH)&&(aw_wait==0);
    ARREADY=(ar_count<QDEPTH)&&(ar_wait==0);

    WREADY=wr_active&&(w_wait==0);

    BVALID=(b_count!=0)&&(b_wait==0);
    BID=(b_count!=0)?b_q[b_head].id:'0;
    BRESP=(b_count!=0)?b_q[b_head].resp:OKAY;

    RVALID=rd_active&&(r_wait==0);
    RID=rd_active?rd_req.id:'0;
    RLAST=rd_active&&(rd_beat==rd_req.len);

    RDATA='0;
    RRESP=OKAY;

    fifo_push=1'b0;
    fifo_pop=1'b0;

    if(rd_active) begin
      logic [15:0] a;
      a=beat_addr(rd_req.addr,rd_beat,rd_req.size,rd_req.burst);

      if(illegal_burst(rd_req.addr,rd_req.len,rd_req.size,rd_req.burst))
        RRESP=SLVERR;
      else begin
        RRESP=address_resp(a);

        if(RRESP==OKAY) begin
          if(is_ram(a))
            RDATA=read_mem(a);
          else
            RDATA=read_reg(a);
        end
      end

      if(RVALID&&RREADY&&(RRESP==OKAY)&&(a==A_FIFO_DATA))
        fifo_pop=1'b1;
    end

    if(wr_active&&WVALID&&WREADY) begin
      logic [15:0] a;
      a=beat_addr(wr_req.addr,wr_beat,wr_req.size,wr_req.burst);

      if(!illegal_burst(wr_req.addr,wr_req.len,wr_req.size,wr_req.burst) &&
         (address_resp(a)==OKAY) &&
         (a==A_FIFO_DATA) &&
         (WSTRB==4'hF) &&
         ctrl[1] &&
         !fifo_full)
        fifo_push=1'b1;
    end
  end

  always_ff @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
      aw_head<=0; aw_tail<=0; aw_count<=0;
      ar_head<=0; ar_tail<=0; ar_count<=0;
      b_head<=0;  b_tail<=0;  b_count<=0;

      ctrl<='0;
      int_en<='0;
      int_status<='0;
      delay_cfg<='0;
      txn_count<='0;

      wr_active<=1'b0;
      wr_req<='0;
      wr_beat<='0;
      wr_resp_accum<=OKAY;

      rd_active<=1'b0;
      rd_req<='0;
      rd_beat<='0;

      aw_wait<=0;
      w_wait<=0;
      ar_wait<=0;
      r_wait<=0;
      b_wait<=0;

      lfsr<=16'h1ACE;

      for(int i=0;i<4096;i++)
        ram[i]<=8'h00;
    end
    else begin
      lfsr<={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};

      if(aw_wait!=0) aw_wait<=aw_wait-1'b1;
      if(w_wait!=0)  w_wait<=w_wait-1'b1;
      if(ar_wait!=0) ar_wait<=ar_wait-1'b1;
      if(r_wait!=0)  r_wait<=r_wait-1'b1;
      if(b_wait!=0)  b_wait<=b_wait-1'b1;

      if(fifo_full)
        int_status[0]<=1'b1;

      if(fifo_empty)
        int_status[1]<=1'b1;

      if(AWVALID&&AWREADY) begin
        aw_q[aw_tail].id<=AWID;
        aw_q[aw_tail].addr<=AWADDR;
        aw_q[aw_tail].len<=AWLEN;
        aw_q[aw_tail].size<=AWSIZE;
        aw_q[aw_tail].burst<=AWBURST;

        aw_tail<=(aw_tail+1)%QDEPTH;
        aw_count<=aw_count+1;
        aw_wait<=make_delay(1'b0);
      end

      if(!wr_active&&(aw_count!=0)) begin
        wr_req<=aw_q[aw_head];
        wr_active<=1'b1;
        wr_beat<=0;
        wr_resp_accum<=illegal_burst(
          aw_q[aw_head].addr,
          aw_q[aw_head].len,
          aw_q[aw_head].size,
          aw_q[aw_head].burst
        )?SLVERR:OKAY;

        aw_head<=(aw_head+1)%QDEPTH;
        aw_count<=aw_count-1;
        w_wait<=make_delay(1'b0);
      end

      if(wr_active&&WVALID&&WREADY) begin
        logic [15:0] a;
        logic [1:0] r;

        a=beat_addr(wr_req.addr,wr_beat,wr_req.size,wr_req.burst);
        r=wr_resp_accum;

        if(illegal_burst(wr_req.addr,wr_req.len,wr_req.size,wr_req.burst)) begin
          r=SLVERR;
          int_status[2]<=1'b1;
        end
        else begin
          r=address_resp(a);

          if(r!=OKAY)
            int_status[2]<=1'b1;

          if(r==OKAY) begin
            if(is_ram(a)) begin
              for(int i=0;i<4;i++)
                if(WSTRB[i]&&((a+i)<=16'h0FFF))
                  ram[a+i]<=WDATA[i*8 +:8];
            end
            else if(a inside {A_STATUS,A_FIFO_STAT,A_TXN_COUNT}) begin
              r=SLVERR;
              int_status[2]<=1'b1;
            end
            else if(a==A_CTRL) begin
              ctrl<=WDATA[2:0];
            end
            else if(a==A_INT_EN) begin
              int_en<=WDATA[2:0];
            end
            else if(a==A_INT_STATUS) begin
              int_status<=int_status&~WDATA[2:0];
            end
            else if(a==A_DELAY_CFG) begin
              delay_cfg<=WDATA[7:0];
            end
            else if(a==A_FIFO_DATA) begin
              if(!ctrl[1]||fifo_full||(WSTRB!=4'hF)) begin
                r=SLVERR;
                int_status[2]<=1'b1;
              end
            end
          end
        end

        if((r!=OKAY)&&(wr_resp_accum==OKAY))
          wr_resp_accum<=r;

        if(WLAST||(wr_beat==wr_req.len)) begin
          b_q[b_tail].id<=wr_req.id;
          b_q[b_tail].resp<=(r!=OKAY)?r:wr_resp_accum;

          b_tail<=(b_tail+1)%QDEPTH;
          b_count<=b_count+1;

          wr_active<=1'b0;
          txn_count<=txn_count+1'b1;
          b_wait<=make_delay(1'b0);
        end
        else begin
          wr_beat<=wr_beat+1'b1;
          w_wait<=make_delay(1'b0);
        end
      end

      if(BVALID&&BREADY) begin
        b_head<=(b_head+1)%QDEPTH;
        b_count<=b_count-1;
        b_wait<=make_delay(1'b0);
      end

      if(ARVALID&&ARREADY) begin
        ar_q[ar_tail].id<=ARID;
        ar_q[ar_tail].addr<=ARADDR;
        ar_q[ar_tail].len<=ARLEN;
        ar_q[ar_tail].size<=ARSIZE;
        ar_q[ar_tail].burst<=ARBURST;

        ar_tail<=(ar_tail+1)%QDEPTH;
        ar_count<=ar_count+1;
        ar_wait<=make_delay(1'b1);
      end

      if(!rd_active&&(ar_count!=0)) begin
        rd_req<=ar_q[ar_head];
        rd_active<=1'b1;
        rd_beat<=0;

        ar_head<=(ar_head+1)%QDEPTH;
        ar_count<=ar_count-1;
        r_wait<=make_delay(1'b1);
      end

      if(rd_active&&RVALID&&RREADY) begin
        if(RRESP!=OKAY)
          int_status[2]<=1'b1;

        if(RLAST) begin
          rd_active<=1'b0;
          txn_count<=txn_count+1'b1;
        end
        else begin
          rd_beat<=rd_beat+1'b1;
          r_wait<=make_delay(1'b1);
        end
      end
    end
  end

endmodule
