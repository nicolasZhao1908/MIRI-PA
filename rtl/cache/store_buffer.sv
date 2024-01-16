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

    // IS LOAD, STORE OR OTHER?
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

  // STB flushes 1 entry
  logic empty;
  logic full;
  logic flush;
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

    // Flush to $ when:
    //  a) is a LW and the data in the entry holds a byte
    //  b) is a ST and is not empty
    //  c) is a ALU operation
    flush = ((stb_ctrl_in == IS_LOAD & data_size_in == W &
                    entries_q[found_idx].data_size == B & valid)
                  | ((stb_ctrl_in == IS_STORE & full)) & ~empty)
                  | stb_ctrl_in == OTHER;

    // The only interaction between STB and cache is writing to the cache
    cache_write_out = flush;

    // Flush to $
    if (flush) begin
      entries_n[read_ptr_q].valid = 0;
      read_ptr_n = read_ptr_q + 1;
      cnt_n = cnt_q - 1;
    end else if ((stb_ctrl_in == IS_STORE) & ~full) begin
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
