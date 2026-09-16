import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_read_base_seq extends uvm_sequence #(axi4_read_txn);
  `uvm_object_utils(axi4_read_base_seq)

  // Configurable transaction knobs
  rand bit [3:0]  seq_id;
  rand bit [15:0] seq_addr;
  rand bit [7:0]  seq_len;
  rand bit [2:0]  seq_size;
  rand bit [1:0]  seq_burst;

  // Negative-test / checking knobs
  bit        allow_illegal = 0;
  bit        check_resp    = 0;
  bit [1:0]  expect_resp   = 2'b00; // OKAY by default
  bit [1:0]  last_resp;
  bit [31:0] last_rdata;

  // Optional read-data check (single-beat convenience)
  bit        check_data  = 0;
  bit [31:0] expect_data = '0;

  function new(string name = "axi4_read_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi4_read_txn tr;
    tr = axi4_read_txn::type_id::create("tr");
    tr.allow_illegal = allow_illegal;

    start_item(tr);

    if (!tr.randomize() with {
      id    == local::seq_id;
      addr  == local::seq_addr;
      len   == local::seq_len;
      size  == local::seq_size;
      burst == local::seq_burst;
    }) begin
      `uvm_error("READ_BASE_SEQ", "Randomization failed for read transaction item")
    end

    finish_item(tr);

    last_resp = tr.final_resp;
    if (tr.data.size() > 0)
      last_rdata = tr.data[0];
    else
      last_rdata = '0;

    if (check_resp && (tr.final_resp !== expect_resp)) begin
      `uvm_error("READ_BASE_SEQ",
        $sformatf("RRESP mismatch @0x%0h: got=%0d expect=%0d (id=%0d len=%0d burst=%0d)",
                  tr.addr, tr.final_resp, expect_resp, tr.id, tr.len, tr.burst))
    end

    if (check_data && (tr.data.size() > 0) && (tr.data[0] !== expect_data)) begin
      `uvm_error("READ_BASE_SEQ",
        $sformatf("RDATA mismatch @0x%0h: got=0x%08h expect=0x%08h",
                  tr.addr, tr.data[0], expect_data))
    end
  endtask

endclass
