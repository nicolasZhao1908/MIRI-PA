`include "brisc_pkg.svh"

module store_buffer
  import brisc_pkg::*;
#(
    parameter int unsigned NUM_ENTRIES = NUM_CACHE_LINES
) (
    input logic clk,
    input logic reset,

    input logic enable,

    input logic is_store,
    input logic is_load,
    input logic [ADDRESS_WIDTH-1:0] addr_in,

    // Add entries
    input logic [XLEN-1:0] write_data_in,
    input data_size_e data_size_in,

    // Evict entries to cache
    output logic [XLEN-1:0] flush_data_out,
    output logic [ADDRESS_WIDTH-1:0] flush_addr_out,
    output logic flush_out,

    // Fowarding and stalling
    output logic [XLEN-1:0] read_data_out,
    output logic [XLEN-1:0] read_addr_out,
    output logic read_valid_out,
    output data_size_e data_size_out
);

  struct packed {
    logic valid;
    data_size_e data_size;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic [XLEN-1:0] data;
  }
      entries_n[NUM_ENTRIES], entries_q[NUM_ENTRIES];

  // Pointers and counters
  logic [$clog2(NUM_ENTRIES)-1:0] read_ptr_n, read_ptr_q;
  logic [$clog2(NUM_ENTRIES)-1:0] write_ptr_n, write_ptr_q;
  logic [$clog2(NUM_ENTRIES):0] cnt_n, cnt_q;

  // STB flushes 1 entry
  logic empty;
  logic full;
  int unsigned found_idx;

  always_comb begin
    /* verilator lint_off WIDTH */

    // Defaults
    entries_n = entries_q;
    write_ptr_n = write_ptr_q;
    read_ptr_n = read_ptr_q;
    cnt_n = cnt_q;
    read_valid_out = 0;

    for (int unsigned i = 0; i < cnt_q; ++i) begin
      found_idx = write_ptr_q - i;
      if (addr_in == entries_q[found_idx].addr & entries_q[found_idx].valid & is_load) begin
        read_valid_out = 1;
        break;
      end
    end

    full = cnt_q == NUM_ENTRIES;
    empty = cnt_q == 0;

    read_data_out = entries_q[found_idx].data;
    read_addr_out = entries_q[found_idx].addr;

    flush_data_out = entries_q[read_ptr_q].data;
    flush_addr_out = entries_q[read_ptr_q].addr;
    data_size_out = entries_q[read_ptr_q].data_size;

    // The only interaction between STB and cache is writing to the cache
    // Flush to $ when:
    //  a) is a LW and the data in the entry holds a byte
    //  b) is a SW/SB and is not empty
    //  c) is other operation that does not use the Cache stage

    flush_out = ((is_store & full) & ~empty) | (~(is_store | is_load) & ~empty);

    // Flush to $
    if (flush_out) begin
      entries_n[read_ptr_q].valid = 0;
      read_ptr_n = read_ptr_q + 1;
      cnt_n = cnt_q - 1;
    end else if (is_store & ~full) begin
      // Store into STB
      entries_n[write_ptr_q].addr = addr_in;
      entries_n[write_ptr_q].valid = 1;
      entries_n[write_ptr_q].data = write_data_in;
      entries_n[write_ptr_q].data_size = data_size_in;

      write_ptr_n = write_ptr_q + 1;
      cnt_n = cnt_q + 1;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_ENTRIES; ++i) begin
        entries_q[i] <= '0;
      end
      write_ptr_q <= '0;
      read_ptr_q <= '0;
      cnt_q <= '0;
    end else if (enable) begin
      entries_q <= entries_n;
      write_ptr_q <= write_ptr_n;
      read_ptr_q <= read_ptr_n;
      cnt_q <= cnt_n;
    end
  end
endmodule
