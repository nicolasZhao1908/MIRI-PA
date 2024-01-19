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
    input logic [ADDRESS_WIDTH-1:0] req_addr,
    input logic [CACHE_LINE_WIDTH-1:0] req_evict_data,
    output logic [CACHE_LINE_WIDTH-1:0] fill_data,
    output logic [ADDRESS_WIDTH-1:0] fill_addr,
    output logic fill

);
  localparam int unsigned WORDS_IN_LINE = CACHE_LINE_WIDTH / WORD_WIDTH;
  localparam int unsigned WORD_OFFSET_WIDTH = $clog2(WORDS_IN_LINE);
  localparam int unsigned BYTE_OFFSET_WIDTH = $clog2(WORD_WIDTH / BYTE_WIDTH);


  logic [XLEN-1:0] datas_n[MEM_DEPTH];
  logic [XLEN-1:0] datas_q[MEM_DEPTH];

  logic [CACHE_LINE_WIDTH-1:0] read_data;
  logic [ADDRESS_WIDTH-BYTE_OFFSET_WIDTH-1:0] word_addr;

  initial begin
    // read both instructions and data
    $readmemh("../../programs/mem.hex", datas_q);
  end

  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic req;
    logic req_store;
  }
      mem_req_aux, mem_req_delayed;

  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic valid;
  }
      fill_aux, fill_delayed;

  always_comb begin
    // Write logic
    word_addr = req_addr[ADDRESS_WIDTH-1:BYTE_OFFSET_WIDTH];

    datas_n = datas_q;

    mem_req_aux.data = req_evict_data;
    mem_req_aux.addr = req_addr;
    mem_req_aux.req = req;
    mem_req_aux.req_store = req_store;

    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      datas_n[word_addr+i] = mem_req_delayed.data[i*WORD_WIDTH+:WORD_WIDTH];
    end

    // Read logic
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      read_data[i*WORD_WIDTH+:WORD_WIDTH] = datas_q[word_addr+i];
    end
    fill_aux.data = read_data;
    fill_aux.addr = req_addr;
    fill_aux.valid = req & ~req_store;

    fill_data = fill_delayed.data;
    fill_addr = fill_delayed.addr;
    fill = fill_delayed.valid;
  end

  always_ff @(posedge clk) begin
    if (mem_req_delayed.req_store & mem_req_delayed.req) begin
      datas_q <= datas_n;
    end
  end

  nff #(
      .N(MEM_REQ_DELAY),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 2)
  ) long_way_in (
      .clk(clk),
      .enable(1'b1),
      // Pipelined mem operations
      .reset(1'b0),
      .inp(mem_req_aux),
      .out(mem_req_delayed)
  );
  nff #(
      .N(MEM_RESP_DELAY),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 1)
  ) long_way_back (
      .clk(clk),
      .enable(1),
      .reset(fill_delayed.valid),
      .inp(fill_aux),
      .out(fill_delayed)
  );



endmodule




