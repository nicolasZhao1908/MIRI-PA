`include "brisc_pkg.svh"
/* verilator lint_off WIDTH  */

module memory
  import brisc_pkg::*;
#(
    parameter integer unsigned DATA_TRANSFER_TIME = MEM_RESP_DELAY,
    parameter int unsigned MEM_DEPTH = brisc_pkg::MEM_DEPTH

) (
    input logic clk,
    input logic req,
    input logic req_store,
    input logic [ADDRESS_WIDTH-1:0] req_address,
    input logic [CACHE_LINE_WIDTH-1:0] req_evict_data,
    output logic [CACHE_LINE_WIDTH-1:0] fill_data,
    output logic [ADDRESS_WIDTH-1:0] fill_address,
    output logic fill

);
  localparam int unsigned WORDS_IN_LINE = CACHE_LINE_WIDTH / WORD_WIDTH;
  localparam int unsigned WORD_OFFSET_WIDTH = $clog2(WORDS_IN_LINE);
  localparam int unsigned BYTE_OFFSET_WIDTH = $clog2(WORD_WIDTH / BYTE_WIDTH);


  logic [XLEN-1:0] datas_n[MEM_DEPTH];
  logic [XLEN-1:0] datas_q[MEM_DEPTH];

  logic [CACHE_LINE_WIDTH-1:0] load_output;
  logic [ADDRESS_WIDTH-BYTE_OFFSET_WIDTH-1:0] word_addr;
  logic [WORD_OFFSET_WIDTH-1:0] word_offset;

  initial begin
    // read both instructions and data
    $readmemh("../../tests/mem.hex", datas_q);
  end

  // WRITE LOGIC
  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic req;
    logic req_store;
  }
      mem_req, mem_req_delayed;

  logic [WORD_WIDTH-1:0] tmp;
  always_comb begin

    // WRITE LOGIC
    word_addr = req_address[ADDRESS_WIDTH-1:BYTE_OFFSET_WIDTH];
    word_offset = req_address[WORD_OFFSET_WIDTH+BYTE_OFFSET_WIDTH-1:BYTE_OFFSET_WIDTH];

    datas_n = datas_q;
    // ASSUME ALIGNED SINCE UNALIGNED MEM OP THROWS AN XCPT IN ALU
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      datas_n[word_addr+i] = mem_req_delayed.data[i*WORD_WIDTH+:WORD_WIDTH];
    end

    mem_req.data = req_evict_data;
    mem_req.addr = req_address;
    mem_req.req = req;
    mem_req.req_store = req_store;

    // READ LOGIC
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      load_output[i*WORD_WIDTH+:WORD_WIDTH] = datas_q[word_addr+i];
    end
    delayed_fill.data = load_output;
    delayed_fill.addr = req_address;
    delayed_fill.valid = req & ~req_store;

    fill_data = fill_out.data;
    fill_address = fill_out.addr;
    fill = fill_out.valid;
  end

  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 2)
  ) long_way_in (
      .clk(clk),
      .enable(1'b1),
      .reset(mem_req_delayed.req),
      .inp(mem_req),
      .out(mem_req_delayed)
  );

  always_ff @(posedge clk) begin
    if (mem_req_delayed.req_store & mem_req_delayed.req) begin
      datas_q <= datas_n;
    end
  end


  // READ LOGIC
  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic valid;
  }
      delayed_fill, fill_out;
  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 1)
  ) long_way_back (
      .clk(clk),
      .enable(1'b1),
      .reset(fill_out.valid),
      .inp(delayed_fill),
      .out(fill_out)
  );


endmodule




