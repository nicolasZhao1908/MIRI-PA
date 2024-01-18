`include "brisc_pkg.svh"

module cache
  import brisc_pkg::*;
#(
    parameter integer unsigned NUM_LINES  = NUM_CACHE_LINES,
    parameter integer unsigned LINE_WIDTH = CACHE_LINE_WIDTH
) (
    input logic clk,
    input logic reset,

    // Inputs
    input logic cache_write,
    input logic [ADDRESS_WIDTH - 1:0] addr,
    input logic [XLEN-1:0] write_data,
    input data_size_e data_size,

    // Mem fill (lines from memory to cache)
    // happens on a load miss only
    input logic fill,
    input logic [LINE_WIDTH - 1:0] fill_data,
    input logic [ADDRESS_WIDTH - 1:0] fill_addr,

    // Eviction (replacing dirty cache lines)
    // in our pipeline: happens on a flush in STB only
    output logic evict,
    output logic [LINE_WIDTH - 1:0] evict_data,
    output logic [ADDRESS_WIDTH - 1:0] evict_addr,

    output logic miss,
    output logic [LINE_WIDTH - 1:0] read_data
);

  localparam int unsigned SET_WIDTH = $clog2(NUM_CACHE_LINES);
  localparam int unsigned OFFSET_WIDTH = $clog2(LINE_WIDTH / BYTE_WIDTH);
  localparam int unsigned TAG_WIDTH = ADDRESS_WIDTH - SET_WIDTH - OFFSET_WIDTH;
  localparam int unsigned BYTE_OFFSET_WIDTH = $clog2(WORD_WIDTH / BYTE_WIDTH);
  localparam int unsigned WORD_OFFSET_WIDTH = $clog2(LINE_WIDTH / WORD_WIDTH);

  // Cache set and tag from address
  logic [SET_WIDTH-1:0] addr_set;
  logic [TAG_WIDTH - 1:0] addr_tag;
  logic [CACHE_LINE_WIDTH - 1:0] cache_line_w;
  logic [BYTE_WIDTH - 1:0] write_byte;

  //  Cache set = Tag store + data store
  struct packed {
    logic valid;
    logic dirty;
    logic [TAG_WIDTH-1:0] tag;
    logic [CACHE_LINE_WIDTH-1:0] data;
  }
      cache_sets_q[NUM_CACHE_LINES], cache_sets_n[NUM_CACHE_LINES];

  logic [WORD_OFFSET_WIDTH-1:0] word_offset;
  logic [OFFSET_WIDTH-1:0] byte_offset;

  always_comb begin
    addr_set = addr[SET_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
    addr_tag = addr[ADDRESS_WIDTH-1:SET_WIDTH+OFFSET_WIDTH];

    word_offset = addr[WORD_OFFSET_WIDTH+BYTE_OFFSET_WIDTH-1:BYTE_OFFSET_WIDTH];
    byte_offset = addr[OFFSET_WIDTH-1:0];

    miss = ~((addr_tag == cache_sets_q[addr_set].tag) & cache_sets_q[addr_set].valid);

    evict = (cache_sets_q[addr_set].dirty & cache_write) & (fill | miss);
    evict_data = cache_sets_q[addr_set].data;
    evict_addr = {cache_sets_q[addr_set].tag, addr_set, {OFFSET_WIDTH{1'b0}}};

    read_data = cache_sets_q[addr_set].data;
    cache_line_w = cache_sets_q[addr_set].data;
    write_byte = write_data[byte_offset*BYTE_OFFSET_WIDTH+:BYTE_WIDTH];


    // default
    cache_sets_n = cache_sets_q;

    if (data_size == W) begin
      cache_line_w[word_offset*WORD_OFFSET_WIDTH+:WORD_WIDTH] = write_data;
      // we only have W and B sizes
    end else begin
      cache_line_w[byte_offset*BYTE_OFFSET_WIDTH+:BYTE_WIDTH] = write_byte;
    end
    // prioritize fill over cache write (tho probably does not matter)
    if (fill) begin
      cache_sets_n[addr_set].data  = fill_data;
      cache_sets_n[addr_set].tag   = addr_tag;
      cache_sets_n[addr_set].dirty = 0;
      cache_sets_n[addr_set].valid = 1;
      // writes from STB
    end else if (cache_write) begin
      cache_sets_n[addr_set].data  = cache_line_w;
      cache_sets_n[addr_set].tag   = addr_tag;
      cache_sets_n[addr_set].dirty = 1;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_CACHE_LINES; ++i) begin
        cache_sets_q[i] <= '0;
      end
    end else if (cache_write | fill) begin
      cache_sets_q <= cache_sets_n;
    end
  end

endmodule
