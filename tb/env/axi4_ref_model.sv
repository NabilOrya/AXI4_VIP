import uvm_pkg::*;
`include "uvm_macros.svh"

// Transaction-level golden model (plan §4.5).
// Built from the verification-plan register map / behavior — not an RTL clone.
// Receives completed observed bursts from monitors, updates shadow state,
// and publishes *expected* write/read txns for the scoreboard.
class axi4_ref_model extends uvm_component;
  `uvm_component_utils(axi4_ref_model)

  virtual axi4_if vif;

  uvm_analysis_imp_write #(axi4_write_txn, axi4_ref_model) write_export;
  uvm_analysis_imp_read  #(axi4_read_txn,  axi4_ref_model) read_export;

  uvm_analysis_port #(axi4_write_txn) exp_write_port;
  uvm_analysis_port #(axi4_read_txn)  exp_read_port;

  // ---- Address map ----
  localparam bit [15:0] A_CTRL       = 16'h1000;
  localparam bit [15:0] A_STATUS     = 16'h1004;
  localparam bit [15:0] A_INT_EN     = 16'h1008;
  localparam bit [15:0] A_INT_STATUS = 16'h100C;
  localparam bit [15:0] A_FIFO_DATA  = 16'h1010;
  localparam bit [15:0] A_FIFO_STAT  = 16'h1014;
  localparam bit [15:0] A_DELAY_CFG  = 16'h1018;
  localparam bit [15:0] A_TXN_COUNT  = 16'h101C;

  localparam bit [1:0] OKAY   = 2'b00;
  localparam bit [1:0] SLVERR = 2'b10;
  localparam bit [1:0] DECERR = 2'b11;

  localparam int FIFO_DEPTH = 16;

  // ---- Shadow state ----
  bit [7:0]  ram[0:4095];
  bit [2:0]  ctrl;        // [0]irq_en [1]fifo_en [2]delay_en
  bit [2:0]  int_en;
  bit [2:0]  int_status;  // [0]full [1]empty [2]error
  bit [7:0]  delay_cfg;
  bit [31:0] txn_count;

  bit [31:0] fifo_q[$];

  function new(string name = "axi4_ref_model", uvm_component parent = null);
    super.new(name, parent);
    write_export   = new("write_export", this);
    read_export    = new("read_export", this);
    exp_write_port = new("exp_write_port", this);
    exp_read_port  = new("exp_read_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      void'(uvm_config_db#(virtual axi4_if)::get(null, "*", "vif", vif));
    do_reset();
    `uvm_info("REF_MODEL", "build_phase: shadow state reset", UVM_LOW)
  endfunction

  // Keep shadow state aligned with DUT on every ARESETn assertion (F1/F34)
  task run_phase(uvm_phase phase);
    if (vif == null) begin
      `uvm_warning("REF_MODEL", "vif not set — cannot track mid-sim reset")
      return;
    end
    forever begin
      wait (vif.ARESETn !== 1'b1);
      do_reset();
      `uvm_info("REF_MODEL", "ARESETn asserted — shadow state cleared", UVM_MEDIUM)
      wait (vif.ARESETn === 1'b1);
    end
  endtask

  // ------------------------------------------------------------------
  // Reset / IRQ / helpers
  // ------------------------------------------------------------------
  virtual function void do_reset();
    foreach (ram[i]) ram[i] = 8'h00;
    ctrl       = 3'b000;
    int_en     = 3'b000;
    int_status = 3'b000;
    delay_cfg  = 8'h00;
    txn_count  = 32'h0;
    fifo_q.delete();
    // F24: empty/full are level-set — FIFO starts empty after reset
    refresh_fifo_level_flags();
  endfunction

  function bit irq_value();
    return ctrl[0] && (|(int_en & int_status));
  endfunction

  function bit fifo_empty();
    return (fifo_q.size() == 0);
  endfunction

  function bit fifo_full();
    return (fifo_q.size() == FIFO_DEPTH);
  endfunction

  function int fifo_level();
    return fifo_q.size();
  endfunction

  // F24: empty/full status bits are level-set (not edge)
  function void refresh_fifo_level_flags();
    if (fifo_full())
      int_status[0] = 1'b1;
    if (fifo_empty())
      int_status[1] = 1'b1;
  endfunction

  function bit [15:0] beat_addr(
      bit [15:0] base, int unsigned beat, bit [2:0] size, bit [1:0] burst);
    if (burst == 2'b00)
      return base;
    return base + (beat << size);
  endfunction

  function bit is_ram(bit [15:0] a);
    return (a <= 16'h0FFF);
  endfunction

  function bit is_reg(bit [15:0] a);
    return (a inside {
      A_CTRL, A_STATUS, A_INT_EN, A_INT_STATUS,
      A_FIFO_DATA, A_FIFO_STAT, A_DELAY_CFG, A_TXN_COUNT
    });
  endfunction

  function bit [1:0] address_resp(bit [15:0] a);
    if ((a >= 16'h2000) && (a <= 16'h2FFF))
      return SLVERR;
    if (is_ram(a) || is_reg(a))
      return OKAY;
    return DECERR;
  endfunction

  function bit illegal_burst(
      bit [15:0] a, bit [7:0] len, bit [2:0] size, bit [1:0] burst);
    bit [16:0] last_a;
    if (len > 8'd15) return 1'b1;
    if (size > 3'd2) return 1'b1;
    if (!(burst inside {2'b00, 2'b01})) return 1'b1;
    last_a = a + (len << size);
    if ((burst == 2'b01) && (a[15:12] != last_a[15:12]))
      return 1'b1;
    return 1'b0;
  endfunction

  function bit [1:0] worse_resp(bit [1:0] a, bit [1:0] b);
    return (b > a) ? b : a;
  endfunction

  function bit [31:0] read_mem(bit [15:0] a);
    bit [31:0] v;
    v = '0;
    for (int i = 0; i < 4; i++)
      if ((a + i) <= 16'h0FFF)
        v[i*8 +: 8] = ram[a + i];
    return v;
  endfunction

  function void write_mem(bit [15:0] a, bit [31:0] data, bit [3:0] strb);
    for (int i = 0; i < 4; i++)
      if (strb[i] && ((a + i) <= 16'h0FFF))
        ram[a + i] = data[i*8 +: 8];
  endfunction

  function bit [31:0] read_reg(bit [15:0] a);
    bit [4:0] lvl;
    // RTL STATUS busy bits: wr_busy=(aw_count!=0)||wr_active, rd_busy=(ar_count!=0)||rd_active.
    // RDATA is formed while rd_active=1, so any STATUS read beat sees rd_busy=1.
    // Phase-1 sequential drivers: wr_busy=0 when predicting a standalone STATUS read.
    lvl = fifo_level();
    case (a)
      A_CTRL:       return {29'h0, ctrl};
      A_STATUS:     return {27'h0, irq_value(), fifo_full(), fifo_empty(), 1'b1, 1'b0};
      A_INT_EN:     return {29'h0, int_en};
      A_INT_STATUS: return {29'h0, int_status};
      A_FIFO_DATA:  return fifo_empty() ? 32'h0 : fifo_q[0];
      A_FIFO_STAT:  return {23'h0, lvl, 2'b0, fifo_full(), fifo_empty()};
      A_DELAY_CFG:  return {24'h0, delay_cfg};
      A_TXN_COUNT:  return txn_count;
      default:      return 32'h0;
    endcase
  endfunction

  // ------------------------------------------------------------------
  // Analysis: observed write from monitor
  // ------------------------------------------------------------------
  function void write_write(axi4_write_txn obs);
    axi4_write_txn exp;
    int unsigned num_beats;
    bit [1:0] accum;
    bit [1:0] beat_resp;
    bit [15:0] a;
    bit [31:0] wdata;
    bit [3:0]  wstrb;

    refresh_fifo_level_flags();

    exp = axi4_write_txn::type_id::create("exp_wr");
    exp.id    = obs.id;
    exp.addr  = obs.addr;
    exp.len   = obs.len;
    exp.size  = obs.size;
    exp.burst = obs.burst;

    num_beats = int'(obs.len) + 1;
    if (obs.data.size() < num_beats)
      num_beats = obs.data.size();
    if (obs.strb.size() < num_beats && obs.strb.size() > 0)
      num_beats = obs.strb.size();

    exp.data = new[num_beats];
    exp.strb = new[num_beats];
    for (int i = 0; i < num_beats; i++) begin
      exp.data[i] = (i < obs.data.size()) ? obs.data[i] : '0;
      exp.strb[i] = (i < obs.strb.size()) ? obs.strb[i] : 4'hF;
    end

    // Illegal burst takes precedence over address decode (plan F35)
    if (illegal_burst(obs.addr, obs.len, obs.size, obs.burst)) begin
      accum = SLVERR;
      int_status[2] = 1'b1;
    end
    else begin
      accum = OKAY;
      for (int i = 0; i < num_beats; i++) begin
        a        = beat_addr(obs.addr, i, obs.size, obs.burst);
        wdata    = exp.data[i];
        wstrb    = exp.strb[i];
        beat_resp = address_resp(a);

        if (beat_resp != OKAY) begin
          accum = worse_resp(accum, beat_resp);
          int_status[2] = 1'b1;
        end
        else if (is_ram(a)) begin
          write_mem(a, wdata, wstrb);
        end
        else begin
          // Register write side-effects
          if (a inside {A_STATUS, A_FIFO_STAT, A_TXN_COUNT}) begin
            beat_resp = SLVERR;
            accum = worse_resp(accum, SLVERR);
            int_status[2] = 1'b1;
          end
          else if (a == A_CTRL) begin
            ctrl = wdata[2:0];
            // fifo_en=0 clears FIFO immediately
            if (!ctrl[1])
              fifo_q.delete();
          end
          else if (a == A_INT_EN) begin
            int_en = wdata[2:0];
          end
          else if (a == A_INT_STATUS) begin
            int_status = int_status & ~wdata[2:0];
          end
          else if (a == A_DELAY_CFG) begin
            delay_cfg = wdata[7:0];
          end
          else if (a == A_FIFO_DATA) begin
            if (!ctrl[1] || fifo_full() || (wstrb != 4'hF)) begin
              beat_resp = SLVERR;
              accum = worse_resp(accum, SLVERR);
              int_status[2] = 1'b1;
            end
            else begin
              fifo_q.push_back(wdata);
            end
          end
        end
      end
    end

    exp.resp = accum;
    txn_count = txn_count + 1;
    refresh_fifo_level_flags();

    `uvm_info("REF_MODEL",
      $sformatf("Predict WR ID=%0d Addr=0x%0h Len=%0d ExpBRESP=%0d IRQ=%0b fifo_lvl=%0d",
                exp.id, exp.addr, exp.len, exp.resp, irq_value(), fifo_level()), UVM_HIGH)

    exp_write_port.write(exp);
  endfunction

  // ------------------------------------------------------------------
  // Analysis: observed read from monitor
  // ------------------------------------------------------------------
  function void write_read(axi4_read_txn obs);
    axi4_read_txn exp;
    int unsigned num_beats;
    bit [15:0] a;
    bit [1:0] beat_resp;

    refresh_fifo_level_flags();

    exp = axi4_read_txn::type_id::create("exp_rd");
    exp.id    = obs.id;
    exp.addr  = obs.addr;
    exp.len   = obs.len;
    exp.size  = obs.size;
    exp.burst = obs.burst;

    num_beats = int'(obs.len) + 1;
    exp.data       = new[num_beats];
    exp.resp       = new[num_beats];
    exp.final_resp = OKAY;

    if (illegal_burst(obs.addr, obs.len, obs.size, obs.burst)) begin
      for (int i = 0; i < num_beats; i++) begin
        exp.data[i] = '0;
        exp.resp[i] = SLVERR;
      end
      exp.final_resp = SLVERR;
      int_status[2]  = 1'b1;
    end
    else begin
      for (int i = 0; i < num_beats; i++) begin
        a         = beat_addr(obs.addr, i, obs.size, obs.burst);
        beat_resp = address_resp(a);
        exp.resp[i] = beat_resp;

        if (beat_resp != OKAY) begin
          exp.data[i] = '0;
          int_status[2] = 1'b1;
        end
        else if (is_ram(a)) begin
          exp.data[i] = read_mem(a);
        end
        else begin
          exp.data[i] = read_reg(a);
          // FIFO pop on successful FIFO_DATA read (Appendix A: empty pop is silent / OKAY)
          if (a == A_FIFO_DATA) begin
            if (!fifo_empty())
              void'(fifo_q.pop_front());
            // Spec lists underflow as error; RTL does not — model matches RTL/Appendix A.
          end
        end

        if (exp.resp[i] > exp.final_resp)
          exp.final_resp = exp.resp[i];
      end
    end

    txn_count = txn_count + 1;
    refresh_fifo_level_flags();

    `uvm_info("REF_MODEL",
      $sformatf("Predict RD ID=%0d Addr=0x%0h Len=%0d ExpRESP=%0d Data0=0x%08h IRQ=%0b",
                exp.id, exp.addr, exp.len, exp.final_resp,
                (exp.data.size() ? exp.data[0] : 0), irq_value()), UVM_HIGH)

    exp_read_port.write(exp);
  endfunction

endclass
