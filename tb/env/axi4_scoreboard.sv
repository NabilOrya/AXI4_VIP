import uvm_pkg::*;
`include "uvm_macros.svh"

// In-order scoreboard (plan §4.6): compare monitor actuals vs ref-model expectations.
class axi4_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi4_scoreboard)

  // Actuals from monitors
  uvm_analysis_imp_write #(axi4_write_txn, axi4_scoreboard) write_export;
  uvm_analysis_imp_read  #(axi4_read_txn,  axi4_scoreboard) read_export;

  // Expectations from reference model
  uvm_analysis_imp_exp_write #(axi4_write_txn, axi4_scoreboard) exp_write_export;
  uvm_analysis_imp_exp_read  #(axi4_read_txn,  axi4_scoreboard) exp_read_export;

  axi4_write_txn exp_wr_q[$];
  axi4_write_txn act_wr_q[$];
  axi4_read_txn  exp_rd_q[$];
  axi4_read_txn  act_rd_q[$];

  int unsigned pass_wr, fail_wr, pass_rd, fail_rd;

  function new(string name = "axi4_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    write_export     = new("write_export", this);
    read_export      = new("read_export", this);
    exp_write_export = new("exp_write_export", this);
    exp_read_export  = new("exp_read_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD", "build_phase executed", UVM_LOW)
  endfunction

  // ---- Actual write ----
  function void write_write(axi4_write_txn t);
    act_wr_q.push_back(t);
    try_match_write();
  endfunction

  // ---- Expected write ----
  function void write_exp_write(axi4_write_txn t);
    exp_wr_q.push_back(t);
    try_match_write();
  endfunction

  // ---- Actual read ----
  function void write_read(axi4_read_txn t);
    act_rd_q.push_back(t);
    try_match_read();
  endfunction

  // ---- Expected read ----
  function void write_exp_read(axi4_read_txn t);
    exp_rd_q.push_back(t);
    try_match_read();
  endfunction

  function void try_match_write();
    axi4_write_txn act, exp;
    bit mismatch;

    while ((act_wr_q.size() > 0) && (exp_wr_q.size() > 0)) begin
      act = act_wr_q.pop_front();
      exp = exp_wr_q.pop_front();
      mismatch = 0;

      if (act.id !== exp.id) begin
        `uvm_error("SCOREBOARD",
          $sformatf("WR ID mismatch: act=%0d exp=%0d Addr=0x%0h", act.id, exp.id, act.addr))
        mismatch = 1;
      end
      if (act.addr !== exp.addr) begin
        `uvm_error("SCOREBOARD",
          $sformatf("WR Addr mismatch: act=0x%0h exp=0x%0h", act.addr, exp.addr))
        mismatch = 1;
      end
      if (act.resp !== exp.resp) begin
        `uvm_error("SCOREBOARD",
          $sformatf("WR BRESP mismatch @0x%0h ID=%0d: act=%0d exp=%0d",
                    act.addr, act.id, act.resp, exp.resp))
        mismatch = 1;
      end

      if (mismatch)
        fail_wr++;
      else begin
        pass_wr++;
        `uvm_info("SCOREBOARD",
          $sformatf("WR MATCH ID=%0d Addr=0x%0h BRESP=%0d", act.id, act.addr, act.resp),
          UVM_MEDIUM)
      end
    end
  endfunction

  function void try_match_read();
    axi4_read_txn act, exp;
    bit mismatch;
    int unsigned n;

    while ((act_rd_q.size() > 0) && (exp_rd_q.size() > 0)) begin
      act = act_rd_q.pop_front();
      exp = exp_rd_q.pop_front();
      mismatch = 0;

      if (act.id !== exp.id) begin
        `uvm_error("SCOREBOARD",
          $sformatf("RD ID mismatch: act=%0d exp=%0d Addr=0x%0h", act.id, exp.id, act.addr))
        mismatch = 1;
      end
      if (act.addr !== exp.addr) begin
        `uvm_error("SCOREBOARD",
          $sformatf("RD Addr mismatch: act=0x%0h exp=0x%0h", act.addr, exp.addr))
        mismatch = 1;
      end
      if (act.final_resp !== exp.final_resp) begin
        `uvm_error("SCOREBOARD",
          $sformatf("RD final RESP mismatch @0x%0h ID=%0d: act=%0d exp=%0d",
                    act.addr, act.id, act.final_resp, exp.final_resp))
        mismatch = 1;
      end

      n = (act.data.size() < exp.data.size()) ? act.data.size() : exp.data.size();
      if (act.data.size() != exp.data.size()) begin
        `uvm_error("SCOREBOARD",
          $sformatf("RD beat-count mismatch @0x%0h: act=%0d exp=%0d",
                    act.addr, act.data.size(), exp.data.size()))
        mismatch = 1;
      end

      for (int i = 0; i < n; i++) begin
        if ((exp.resp.size() > i) && (act.resp.size() > i) && (act.resp[i] !== exp.resp[i])) begin
          `uvm_error("SCOREBOARD",
            $sformatf("RD per-beat RESP mismatch @0x%0h beat=%0d: act=%0d exp=%0d",
                      act.addr, i, act.resp[i], exp.resp[i]))
          mismatch = 1;
        end
        // Compare RDATA only on OKAY beats
        if ((exp.resp.size() > i) && (exp.resp[i] == 2'b00) && (act.data[i] !== exp.data[i])) begin
          `uvm_error("SCOREBOARD",
            $sformatf("RD DATA mismatch @0x%0h beat=%0d: act=0x%08h exp=0x%08h",
                      act.addr, i, act.data[i], exp.data[i]))
          mismatch = 1;
        end
      end

      if (mismatch)
        fail_rd++;
      else begin
        pass_rd++;
        `uvm_info("SCOREBOARD",
          $sformatf("RD MATCH ID=%0d Addr=0x%0h RESP=%0d Data0=0x%08h",
                    act.id, act.addr, act.final_resp,
                    (act.data.size() ? act.data[0] : 0)), UVM_MEDIUM)
      end
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (act_wr_q.size() || exp_wr_q.size())
      `uvm_error("SCOREBOARD",
        $sformatf("Unmatched write txns at end: act=%0d exp=%0d",
                  act_wr_q.size(), exp_wr_q.size()))
    if (act_rd_q.size() || exp_rd_q.size())
      `uvm_error("SCOREBOARD",
        $sformatf("Unmatched read txns at end: act=%0d exp=%0d",
                  act_rd_q.size(), exp_rd_q.size()))
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCOREBOARD",
      $sformatf("Results: WR pass=%0d fail=%0d | RD pass=%0d fail=%0d",
                pass_wr, fail_wr, pass_rd, fail_rd), UVM_LOW)
  endfunction

endclass
