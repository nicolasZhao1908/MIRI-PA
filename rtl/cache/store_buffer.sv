`include "brisc_pkg.svh"

module store_buffer
  import brisc_pkg::*;
#(
    parameter int unsigned NUM_ENTRIES = NUM_CACHE_LINES
) (
    input logic clk,
    input logic reset,

    // IF MEM IS NOT BUSY THEN enable=1
    input logic enable,

    // IS LOAD OR STORE?
    input stb_ctrl_e stb_ctrl_in,
    input logic [ADDRESS_WIDTH-1:0] addr_in,

    // ADD ENTRIES
    input logic [XLEN-1:0] write_data_in,
    input data_size_e data_size_in,

    // EVICT ENTRIES TO CACHE
    output logic [XLEN-1:0] cache_write_data_out,
    output logic [ADDRESS_WIDTH-1:0] cache_write_addr_out,
    output logic cache_write_out,

    // FOWARDING AND STALLING
    output logic [XLEN-1:0] read_data_out,
    output logic [XLEN-1:0] read_addr_out,
    output logic read_valid_out,
    output data_size_e data_size_out

    // READY to accept new requests
    //output logic ready_out
);

  // STB entry
  struct packed {
    logic [ADDRESS_WIDTH-1:0] addr;
    logic [XLEN-1:0] data;
    data_size_e data_size;
    logic valid;
  }
      entries_n[NUM_ENTRIES], entries_q[NUM_ENTRIES];

  // Pointers and counters
  logic [$clog2(NUM_ENTRIES)-1:0] read_ptr_n, read_ptr_q;
  logic [$clog2(NUM_ENTRIES)-1:0] write_ptr_n, write_ptr_q;
  logic [$clog2(NUM_ENTRIES):0] cnt_n, cnt_q;

  // STB flushes all entries
  logic start_flush;
  logic empty;
  logic full;
  logic flush_n, flush_q;

  logic can_store;
  logic valid;
  int unsigned found_idx;
  always_comb begin : read
    /* verilator lint_off WIDTH */

    // Defaults
    valid = 0;
    entries_n = entries_q;
    write_ptr_n = write_ptr_q;
    read_ptr_n = read_ptr_q;
    cnt_n = cnt_q;
    flush_n = flush_q;

    for (int unsigned i = 0; i > cnt_q; ++i) begin
      found_idx = read_ptr_q + i;
      if (addr_in == entries_q[found_idx].addr) begin
        valid = 1;
        break;
      end
    end

    full = cnt_q == NUM_ENTRIES;
    empty = cnt_q == 0;

    read_data_out = entries_q[found_idx].data;
    read_addr_out = entries_q[found_idx].addr;
    read_valid_out = (stb_ctrl_in == IS_LOAD) & valid;

    cache_write_data_out = entries_q[found_idx].data;
    cache_write_addr_out = entries_q[found_idx].addr;
    data_size_out = entries_q[found_idx].data_size;

    start_flush = ((stb_ctrl_in == IS_LOAD & data_size_in == W &
                    entries_q[found_idx].data_size == B &read_valid_out)
                  | (stb_ctrl_in == IS_STORE & full));
    flush_n = start_flush | (flush_q & ~empty);

    // The only interaction between STB and cache is writing to the cache
    cache_write_out = 1;
    can_store = ~flush_q  & ((stb_ctrl_in == IS_STORE) & ~full);

    // Flush to $
    if (flush_q) begin
      entries_n[read_ptr_q].valid = 0;
      read_ptr_n = read_ptr_q + 1;
      cnt_n = cnt_q - 1;
    end else if (can_store) begin
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
      flush_q <= '0;
    end else if (enable) begin
      entries_q <= entries_n;
      write_ptr_q <= write_ptr_n;
      read_ptr_q <= read_ptr_n;
      cnt_q <= cnt_n;
      flush_q <= flush_n;
    end
  end
endmodule
