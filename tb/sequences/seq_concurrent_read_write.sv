// Sequence #50: seq_concurrent_read_write (Virtual Sequence)
// Feature: F31 (Channel Independence — Concurrent Read and Write Bursts)
// Objective: Forks write and read sequences concurrently on write_agent and read_agent sequencers.

import uvm_pkg::*;
`include "uvm_macros.svh"

class seq_concurrent_read_write extends axi4_vseq_base;
  `uvm_object_utils(seq_concurrent_read_write)

  function new(string name = "seq_concurrent_read_write");
    super.new(name);
  endfunction

  virtual task body();
    seq_legal_incr_burst_write wr_seq;
    seq_legal_incr_burst_read  rd_seq;

    `uvm_info("SEQ_CONCURRENT_RW", "Executing Sequence #50: Concurrent Read and Write Virtual Sequence", UVM_LOW)

    wr_seq = seq_legal_incr_burst_write::type_id::create("wr_seq");
    rd_seq = seq_legal_incr_burst_read::type_id::create("rd_seq");

    fork
      begin
        if (write_seqr != null)
          wr_seq.start(write_seqr);
        else
          `uvm_error("SEQ_CONCURRENT_RW", "write_seqr handle is null!")
      end
      begin
        if (read_seqr != null)
          rd_seq.start(read_seqr);
        else
          `uvm_error("SEQ_CONCURRENT_RW", "read_seqr handle is null!")
      end
    join

    `uvm_info("SEQ_CONCURRENT_RW", "Sequence #50 completed", UVM_LOW)
  endtask

endclass
