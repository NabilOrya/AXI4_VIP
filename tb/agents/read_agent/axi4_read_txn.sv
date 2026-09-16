import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_read_txn extends uvm_sequence_item;

  // AR Channel Signals
  rand bit [3:0]  id;
  rand bit [15:0] addr;
  rand bit [7:0]  len;    // Burst length: 0 to 15 (1 to 16 beats)
  rand bit [2:0]  size;   // 0=1 byte, 1=2 bytes, 2=4 bytes
  rand bit [1:0]  burst;  // 0=FIXED, 1=INCR, 2=WRAP, 3=Reserved

  // R Channel Signals (Sampled by Monitor/Driver)
  bit [31:0] data[];
  bit [1:0]  resp[];
  bit [1:0]  final_resp;

  // When set, legal-only constraints are disabled (negative tests)
  bit allow_illegal = 0;

  `uvm_object_utils_begin(axi4_read_txn)
    `uvm_field_int(id, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(len, UVM_ALL_ON)
    `uvm_field_int(size, UVM_ALL_ON)
    `uvm_field_int(burst, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_field_array_int(resp, UVM_ALL_ON)
    `uvm_field_int(final_resp, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_len   { if (!allow_illegal) len inside {[0:15]}; }
  constraint c_size  { if (!allow_illegal) size inside {3'b000, 3'b001, 3'b010}; }
  constraint c_burst { if (!allow_illegal) burst inside {2'b00, 2'b01}; }

  function new(string name = "axi4_read_txn");
    super.new(name);
  endfunction

  function void post_randomize();
    `uvm_info("READ_TXN", $sformatf("Randomized Read Txn: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
              id, addr, len, size, burst), UVM_HIGH)
  endfunction

endclass
