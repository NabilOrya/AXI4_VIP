import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_write_base_seq extends uvm_sequence #(axi4_write_txn);
  `uvm_object_utils(axi4_write_base_seq)

  // Configurable transaction knobs
  rand bit [3:0]  seq_id;
  rand bit [15:0] seq_addr;
  rand bit [7:0]  seq_len;
  rand bit [2:0]  seq_size;
  rand bit [1:0]  seq_burst;

  rand bit [31:0] seq_data[];
  rand bit [3:0]  seq_strb[];

  // Helper flags
  bit override_data = 0;
  bit override_strb = 0;
  bit [3:0] fixed_strb = 4'hF;

  // Negative-test / checking knobs
  bit        allow_illegal = 0;
  bit        check_resp    = 0;
  bit [1:0]  expect_resp   = 2'b00; // OKAY by default
  bit [1:0]  last_resp;

  function new(string name = "axi4_write_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi4_write_txn tr;
    tr = axi4_write_txn::type_id::create("tr");
    tr.allow_illegal = allow_illegal;

    start_item(tr);

    if (!tr.randomize() with {
      id    == local::seq_id;
      addr  == local::seq_addr;
      len   == local::seq_len;
      size  == local::seq_size;
      burst == local::seq_burst;
    }) begin
      `uvm_error("WRITE_BASE_SEQ", "Randomization failed for write transaction item")
    end

    if (override_data && seq_data.size() == tr.data.size()) begin
      foreach (seq_data[i]) tr.data[i] = seq_data[i];
    end

    if (override_strb && seq_strb.size() == tr.strb.size()) begin
      foreach (seq_strb[i]) tr.strb[i] = seq_strb[i];
    end else begin
      foreach (tr.strb[i]) tr.strb[i] = fixed_strb;
    end

    finish_item(tr);

    last_resp = tr.resp;

    if (check_resp && (tr.resp !== expect_resp)) begin
      `uvm_error("WRITE_BASE_SEQ",
        $sformatf("BRESP mismatch @0x%0h: got=%0d expect=%0d (id=%0d len=%0d burst=%0d)",
                  tr.addr, tr.resp, expect_resp, tr.id, tr.len, tr.burst))
    end
  endtask

endclass
