import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_write_txn extends uvm_sequence_item;

  // AW Channel Signals
  rand bit [3:0]  id;
  rand bit [15:0] addr;
  rand bit [7:0]  len;    // Burst length: 0 to 15 (1 to 16 beats)
  rand bit [2:0]  size;   // 0=1 byte, 1=2 bytes, 2=4 bytes
  rand bit [1:0]  burst;  // 0=FIXED, 1=INCR, 2=WRAP, 3=Reserved

  // W Channel Signals
  rand bit [31:0] data[];
  rand bit [3:0]  strb[];

  // B Channel Signal (Sampled by Monitor/Driver)
  bit [1:0]       resp;   // 0=OKAY, 1=EXOKAY, 2=SLVERR, 3=DECERR

  // When set, legal-only constraints are disabled (negative tests)
  bit allow_illegal = 0;

  `uvm_object_utils_begin(axi4_write_txn)
    `uvm_field_int(id, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(len, UVM_ALL_ON)
    `uvm_field_int(size, UVM_ALL_ON)
    `uvm_field_int(burst, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_field_array_int(strb, UVM_ALL_ON)
    `uvm_field_int(resp, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constraints for legal default values (disabled when allow_illegal=1)
  constraint c_len   { if (!allow_illegal) len inside {[0:15]}; }
  constraint c_size  { if (!allow_illegal) size inside {3'b000, 3'b001, 3'b010}; }
  constraint c_burst { if (!allow_illegal) burst inside {2'b00, 2'b01}; }

  // Array sizes must match number of beats (len + 1)
  constraint c_data_size {
    data.size() == len + 1;
    strb.size() == len + 1;
  }

  function new(string name = "axi4_write_txn");
    super.new(name);
  endfunction

  function void post_randomize();
    `uvm_info("WRITE_TXN", $sformatf("Randomized Txn: ID=%0d Addr=0x%0h Len=%0d Size=%0d Burst=%0d",
              id, addr, len, size, burst), UVM_HIGH)
  endfunction

endclass
