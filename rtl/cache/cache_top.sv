`include "brisc_pkg.svh"

module cache_top
  import brisc_pkg::*;
#(
    parameter integer unsigned NUM_LINES = NUM_CACHE_LINES,
    parameter integer unsigned ADDR_WIDTH = ADDRESS_WIDTH,
    parameter integer unsigned LINE_WIDTH = CACHE_LINE_WIDTH
) (
    // PIPELINE
    input logic clk,
    input logic reset,
    input logic enable,
    input logic is_load,
    input logic [ADDR_WIDTH-1:0] addr,
    input data_size_e data_size,
    output logic miss,
    output logic [XLEN-1:0] read_data,

    // ARBITER
    input logic arbiter_grant,
    output logic arbiter_req,
    output logic [ADDR_WIDTH-1:0] mem_req_addr,
    output logic [LINE_WIDTH-1:0] mem_req_data,
    output logic mem_req_write,

    // MEMORY
    input logic mem_resp,
    input logic [LINE_WIDTH-1:0] mem_resp_data,
    input logic [ADDR_WIDTH-1:0] mem_resp_addr,

    // SB
    input logic [XLEN-1:0] stb_write_data,
    input logic [ADDR_WIDTH-1:0] stb_write_addr,
    input logic stb_read_valid,
    input logic stb_write,
    input data_size_e stb_write_size
);
  localparam int unsigned OFFSET_WIDTH = $clog2(WORD_WIDTH / BYTE_WIDTH);
  localparam int unsigned WORD_OFFSET_WIDTH = $clog2(LINE_WIDTH / WORD_WIDTH);

  logic [WORD_OFFSET_WIDTH-1:0] word_offset;
  logic [OFFSET_WIDTH-1:0] byte_offset;
  logic [WORD_WIDTH-1:0] read_word;
  logic [BYTE_WIDTH-1:0] read_byte;

  logic cache_write;
  logic cache_miss;
  logic [LINE_WIDTH-1:0] cache_line;
  logic [XLEN-1:0] write_data;
  logic [XLEN-1:0] write_word;
  logic cache_evict;

  cache #(
      .LINE_WIDTH(LINE_WIDTH)
  ) cache (
      .clk(clk),
      .reset(reset),
      .data_size(data_size),
      .enable(stb_write | mem_resp),
      .addr(addr),
      .write_data(stb_write_data),

      // write from STB
      .cache_write(stb_write),

      // output for cache
      .read_data(cache_line),
      .miss(cache_miss),

      // input fill from mem and arbiter
      .fill(mem_resp & arbiter_grant),
      .fill_data(mem_resp_data),
      .fill_addr(mem_resp_addr),

      // output for eviction
      .evict(cache_evict),
      .evict_data(mem_req_data),
      .evict_addr(mem_req_addr)
  );

  // STALL LOGIC: cache_miss & store_buffer_miss

  always_comb begin
    miss = cache_miss;
    arbiter_req = cache_evict | (cache_miss & (~stb_read_valid) & is_load);
    mem_req_write = cache_evict;

    // MUX result data
    word_offset = addr[OFFSET_WIDTH-1:OFFSET_WIDTH-WORD_OFFSET_WIDTH];
    byte_offset = addr[OFFSET_WIDTH-1:0];
    read_word = cache_line[WORD_WIDTH*word_offset-1+:WORD_WIDTH];
    read_byte = cache_line[BYTE_WIDTH*byte_offset-1+:BYTE_WIDTH];
    read_data = (data_size == W) ? read_word : {{24{1'b0}}, read_byte};
  end
endmodule
