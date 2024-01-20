`include "brisc_pkg.svh"

module cache_top
  import brisc_pkg::*;
#(
    parameter integer unsigned NUM_LINES  = NUM_CACHE_LINES,
    parameter integer unsigned ADDR_WIDTH = ADDRESS_WIDTH,
    parameter integer unsigned LINE_WIDTH = CACHE_LINE_WIDTH
) (
    // Pipeline
    input logic clk,
    input logic reset,

    input logic [ADDR_WIDTH-1:0] addr,
    input data_size_e data_size,
    output logic [XLEN-1:0] read_data,
    input logic is_load,
    input logic is_store,

    // Arbiter
    input logic arbiter_grant,

    // Memory
    output logic mem_req,
    output logic mem_req_write,
    output logic [ADDR_WIDTH-1:0] mem_req_addr,
    output logic [LINE_WIDTH-1:0] mem_req_data,
    input logic mem_resp,
    input logic [LINE_WIDTH-1:0] mem_resp_data,
    input logic [ADDR_WIDTH-1:0] mem_resp_addr,

    // STB
    input logic [XLEN-1:0] stb_write_data,
    input logic [ADDR_WIDTH-1:0] stb_write_addr,
    input logic stb_write,
    input data_size_e stb_write_size,
    input logic stb_read_valid
);
  localparam int unsigned OFFSET_WIDTH = $clog2(LINE_WIDTH / BYTE_WIDTH);
  localparam int unsigned WORD_OFFSET_WIDTH = $clog2(LINE_WIDTH / WORD_WIDTH);

  logic [WORD_OFFSET_WIDTH-1:0] word_offset;
  logic [OFFSET_WIDTH-1:0] byte_offset;
  logic [WORD_WIDTH-1:0] read_word;
  logic [BYTE_WIDTH-1:0] read_byte;

  logic [LINE_WIDTH-1:0] cache_line;
  logic [XLEN-1:0] write_data;
  logic [XLEN-1:0] write_word;
  logic [ADDRESS_WIDTH-1:0] evict_addr;
  logic cache_evict;
  logic cache_miss;
  logic can_fill, can_fill_w;
  logic needs_fill;

  cache #(
      .LINE_WIDTH(LINE_WIDTH)
  ) cache_unit (
      .clk(clk),
      .reset(reset),
      .data_size(data_size),
      .addr(addr),
      .grant(arbiter_grant),

      // Cache only receives writes from STB
      .cache_write(stb_write),
      .write_data (stb_write_data),
      .write_addr (stb_write_addr),

      .read_data(cache_line),
      .miss(cache_miss),
      .is_mem(is_load | is_store),

      // Fill: requested memory line goes to cache
      .fill(can_fill),
      .fill_data(mem_resp_data),
      .fill_addr(mem_resp_addr),

      // Eviction: replaced dirty line goes to mem
      .evict(cache_evict),
      .evict_data(mem_req_data),
      .evict_addr(evict_addr)
  );

  enum logic [1:0] {
    IDLE,
    WAIT_EVICT,
    WAIT_FILL
  }
      state_q, state_n;

  always_comb begin
    // Store (evict dirty line) OR load (don't hit in either cache or STB)
    can_fill = mem_resp & arbiter_grant & (mem_resp_addr == {addr[ADDRESS_WIDTH-1:OFFSET_WIDTH], {OFFSET_WIDTH{1'b0}}});
    // For some reason verilator needs it (it warns about combinational loop)
    can_fill_w = mem_resp & arbiter_grant & (mem_resp_addr == {addr[ADDRESS_WIDTH-1:OFFSET_WIDTH], {OFFSET_WIDTH{1'b0}}});

    needs_fill = is_load & (cache_miss & ~stb_read_valid);

    mem_req = cache_evict | needs_fill;
    mem_req_write = cache_evict;
    mem_req_addr = {addr[ADDRESS_WIDTH-1:OFFSET_WIDTH], {OFFSET_WIDTH{1'b0}}};

    unique case (state_q)
      IDLE: begin
        state_n = IDLE;
        if (mem_req) begin
          if (mem_req_write) begin
            mem_req_addr = evict_addr;
            mem_req_write = 1;
            state_n = WAIT_EVICT;
          end else begin
            state_n = WAIT_FILL;
          end
        end
      end
      WAIT_EVICT: begin
        if (arbiter_grant) begin
          if (cache_miss) begin
            mem_req = 1;
            mem_req_write = 0;
            state_n = WAIT_FILL;
          end else begin
            mem_req = 0;
            state_n = IDLE;
          end
        end
      end
      WAIT_FILL: begin
        mem_req_write = 0;
        state_n = can_fill_w ? IDLE : WAIT_FILL;
      end
    endcase

    // MUX result data
    word_offset = addr[OFFSET_WIDTH-1:OFFSET_WIDTH-WORD_OFFSET_WIDTH];
    byte_offset = addr[OFFSET_WIDTH-1:0];
    read_word   = cache_line[WORD_WIDTH*word_offset+:WORD_WIDTH];
    read_byte   = cache_line[BYTE_WIDTH*byte_offset+:BYTE_WIDTH];
    read_data   = (data_size == W) ? read_word : {{24{1'b0}}, read_byte};
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_n;
    end
  end
endmodule
