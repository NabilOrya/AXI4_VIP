// Functional Coverage Component: axi4_coverage.sv
// Section 4.7 of UVM Verification Plan
// Implements 10 covergroups: cg_burst, cg_addr_region, cg_wstrb, cg_id, cg_outstanding, cg_ctrl, cg_irq, cg_fifo, cg_delay, cg_resp

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_coverage extends uvm_component;
  `uvm_component_utils(axi4_coverage)

  uvm_analysis_imp_write #(axi4_write_txn, axi4_coverage) write_export;
  uvm_analysis_imp_read  #(axi4_read_txn,  axi4_coverage) read_export;

  virtual axi4_if vif;

  // Sampling Variables
  bit [1:0]   sample_burst_type;
  bit [2:0]   sample_transfer_size;
  int         sample_burst_len;
  bit [15:0]  sample_addr;
  bit         sample_access_dir; // 0=Write, 1=Read
  bit [3:0]   sample_wstrb;
  bit [3:0]   sample_id;
  bit         sample_same_id_b2b;
  int         sample_aw_outstanding;
  int         sample_ar_outstanding;
  bit         sample_irq_en;
  bit         sample_fifo_en;
  bit         sample_delay_en;
  bit [2:0]   sample_int_en;
  bit [2:0]   sample_int_status;
  bit         sample_irq;
  int         sample_fifo_level;
  int         sample_fifo_op; // 0=None, 1=Push, 2=Pop, 3=Simultaneous
  bit [3:0]   sample_wr_delay;
  bit [3:0]   sample_rd_delay;
  bit [1:0]   sample_resp;
  bit         sample_resp_chan; // 0=Write (B), 1=Read (R)

  bit [3:0]   last_write_id = 4'hF;
  bit [3:0]   last_read_id  = 4'hF;

  // 1. Covergroup: cg_burst
  covergroup cg_burst;
    option.per_instance = 1;
    cp_burst_type: coverpoint sample_burst_type {
      bins FIXED = {2'b00};
      bins INCR  = {2'b01};
      bins WRAP  = {2'b10};
      bins RSVD  = {2'b11};
    }
    cp_transfer_size: coverpoint sample_transfer_size {
      bins SIZE_1B = {3'b000};
      bins SIZE_2B = {3'b001};
      bins SIZE_4B = {3'b010};
      bins ILLEGAL = {[3'b011:3'b111]};
    }
    cp_burst_len: coverpoint sample_burst_len {
      bins SINGLE         = {0};
      bins SHORT          = {[1:7]};
      bins LONG           = {[8:14]};
      bins MAX_16         = {15};
      bins ILLEGAL_OVER15 = {[16:255]};
    }
    cross_burst_size_len: cross cp_burst_type, cp_transfer_size, cp_burst_len;
  endgroup

  // 2. Covergroup: cg_addr_region
  covergroup cg_addr_region;
    option.per_instance = 1;
    cp_region: coverpoint sample_addr {
      bins RAM            = {[16'h0000:16'h0FFF]};
      bins REG_CTRL       = {16'h1000};
      bins REG_STATUS     = {16'h1004};
      bins REG_INT_EN     = {16'h1008};
      bins REG_INT_STATUS = {16'h100C};
      bins REG_FIFO_DATA  = {16'h1010};
      bins REG_FIFO_STAT  = {16'h1014};
      bins REG_DELAY_CFG  = {16'h1018};
      bins REG_TXN_COUNT  = {16'h101C};
      bins SLVERR_WINDOW  = {[16'h2000:16'h2FFF]};
      bins UNMAPPED       = default;
    }
    cp_access_dir: coverpoint sample_access_dir {
      bins WRITE = {1'b0};
      bins READ  = {1'b1};
    }
    cross_region_dir: cross cp_region, cp_access_dir;
  endgroup

  // 3. Covergroup: cg_wstrb
  covergroup cg_wstrb;
    option.per_instance = 1;
    cp_wstrb_pattern: coverpoint sample_wstrb {
      bins ALL_ONES    = {4'hF};
      bins SINGLE_BYTE = {4'h1, 4'h2, 4'h4, 4'h8};
      bins SPARSE      = {4'h3, 4'h5, 4'h6, 4'h9, 4'hA, 4'hC, 4'hD, 4'hE};
      bins NONE        = {4'h0};
    }
    cp_region_type: coverpoint (sample_addr <= 16'h0FFF) {
      bins RAM_REGION = {1'b1};
      bins REG_REGION = {1'b0};
    }
    cross_wstrb_region: cross cp_wstrb_pattern, cp_region_type;
  endgroup

  // 4. Covergroup: cg_id
  covergroup cg_id;
    option.per_instance = 1;
    cp_id_val: coverpoint sample_id {
      bins ID_BINS[] = {[0:15]};
    }
    cp_same_id: coverpoint sample_same_id_b2b {
      bins DIFF_ID = {1'b0};
      bins SAME_ID = {1'b1};
    }
    cross_id_b2b: cross cp_id_val, cp_same_id;
  endgroup

  // 5. Covergroup: cg_outstanding
  covergroup cg_outstanding;
    option.per_instance = 1;
    cp_aw_outstanding: coverpoint sample_aw_outstanding {
      bins BINS[] = {[0:4]};
    }
    cp_ar_outstanding: coverpoint sample_ar_outstanding {
      bins BINS[] = {[0:4]};
    }
    cross_outstanding: cross cp_aw_outstanding, cp_ar_outstanding;
  endgroup

  // 6. Covergroup: cg_ctrl
  covergroup cg_ctrl;
    option.per_instance = 1;
    cp_irq_en:   coverpoint sample_irq_en;
    cp_fifo_en:  coverpoint sample_fifo_en;
    cp_delay_en: coverpoint sample_delay_en;
    cross_ctrl_comb: cross cp_irq_en, cp_fifo_en, cp_delay_en;
  endgroup

  // 7. Covergroup: cg_irq
  covergroup cg_irq;
    option.per_instance = 1;
    cp_int_en: coverpoint sample_int_en {
      bins NONE = {3'b000};
      bins SOME = {[3'b001:3'b110]};
      bins ALL  = {3'b111};
    }
    cp_int_status: coverpoint sample_int_status {
      bins NONE       = {3'b000};
      bins FIFO_FULL  = {3'b001};
      bins FIFO_EMPTY = {3'b010};
      bins ERROR_EVENT= {3'b100};
      bins MULTIPLE   = default;
    }
    cp_irq: coverpoint sample_irq;
    cross_irq_formula: cross cp_int_en, cp_int_status, cp_irq;
  endgroup

  // 8. Covergroup: cg_fifo
  covergroup cg_fifo;
    option.per_instance = 1;
    cp_fifo_level: coverpoint sample_fifo_level {
      bins EMPTY     = {0};
      bins MID_LEVEL = {[1:15]};
      bins FULL      = {16};
    }
    cp_fifo_op: coverpoint sample_fifo_op {
      bins NO_OP = {0};
      bins PUSH  = {1};
      bins POP   = {2};
      bins BOTH  = {3};
    }
    cross_fifo_state_op: cross cp_fifo_level, cp_fifo_op;
  endgroup

  // 9. Covergroup: cg_delay
  covergroup cg_delay;
    option.per_instance = 1;
    cp_delay_en: coverpoint sample_delay_en;
    cp_wr_delay: coverpoint sample_wr_delay {
      bins ZERO = {0};
      bins LOW  = {[1:5]};
      bins HIGH = {[6:14]};
      bins MAX  = {15};
    }
    cp_rd_delay: coverpoint sample_rd_delay {
      bins ZERO = {0};
      bins LOW  = {[1:5]};
      bins HIGH = {[6:14]};
      bins MAX  = {15};
    }
    cross_delay_wr: cross cp_delay_en, cp_wr_delay;
    cross_delay_rd: cross cp_delay_en, cp_rd_delay;
  endgroup

  // 10. Covergroup: cg_resp
  covergroup cg_resp;
    option.per_instance = 1;
    cp_resp_code: coverpoint sample_resp {
      bins OKAY   = {2'b00};
      bins EXOKAY = {2'b01};
      bins SLVERR = {2'b10};
      bins DECERR = {2'b11};
    }
    cp_resp_channel: coverpoint sample_resp_chan {
      bins WRITE_B = {1'b0};
      bins READ_R  = {1'b1};
    }
    cross_resp: cross cp_resp_code, cp_resp_channel;
  endgroup

  function new(string name = "axi4_coverage", uvm_component parent = null);
    super.new(name, parent);
    write_export = new("write_export", this);
    read_export  = new("read_export", this);

    cg_burst        = new();
    cg_addr_region  = new();
    cg_wstrb        = new();
    cg_id           = new();
    cg_outstanding  = new();
    cg_ctrl         = new();
    cg_irq          = new();
    cg_fifo         = new();
    cg_delay        = new();
    cg_resp         = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("COVERAGE", "build_phase executed", UVM_LOW)
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_info("COVERAGE", "Virtual interface vif not set in config DB (optional for transaction coverage)", UVM_MEDIUM)
  endfunction

  function void write_write(axi4_write_txn t);
    `uvm_info("COVERAGE", $sformatf("Sampling Write Txn Coverage: ID=%0d Addr=0x%0h", t.id, t.addr), UVM_HIGH)
    sample_burst_type    = t.burst;
    sample_transfer_size = t.size;
    sample_burst_len     = t.len;
    sample_addr          = t.addr;
    sample_access_dir    = 1'b0; // Write
    sample_wstrb         = (t.strb.size() > 0) ? t.strb[0] : 4'hF;
    sample_id            = t.id;
    sample_same_id_b2b   = (t.id == last_write_id);
    last_write_id        = t.id;
    sample_resp          = t.resp;
    sample_resp_chan     = 1'b0; // Write B

    cg_burst.sample();
    cg_addr_region.sample();
    cg_wstrb.sample();
    cg_id.sample();
    cg_resp.sample();
  endfunction

  function void write_read(axi4_read_txn t);
    `uvm_info("COVERAGE", $sformatf("Sampling Read Txn Coverage: ID=%0d Addr=0x%0h", t.id, t.addr), UVM_HIGH)
    sample_burst_type    = t.burst;
    sample_transfer_size = t.size;
    sample_burst_len     = t.len;
    sample_addr          = t.addr;
    sample_access_dir    = 1'b1; // Read
    sample_id            = t.id;
    sample_same_id_b2b   = (t.id == last_read_id);
    last_read_id         = t.id;
    sample_resp          = t.final_resp;
    sample_resp_chan     = 1'b1; // Read R

    cg_burst.sample();
    cg_addr_region.sample();
    cg_id.sample();
    cg_resp.sample();
  endfunction

endclass
