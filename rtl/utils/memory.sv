`include "brisc_pkg.svh"


module memory
  import brisc_pkg::*;
#(
    parameter integer unsigned DATA_TRANSFER_TIME = MEM_RESP_DELAY,
    parameter int unsigned MEM_DEPTH = 300

) (
    input logic clk,
    input logic req,
    input logic req_store,
    input logic [ADDRESS_WIDTH-1:0] req_address,
    input logic [CACHE_LINE_WIDTH-1:0] req_evict_data,
    output logic [CACHE_LINE_WIDTH-1:0] fill_data,
    output logic [CACHE_LINE_WIDTH-1:0] fill_address,
    output logic fill

);
  localparam int unsigned LINE_OFFSET = $clog2(WORD_WIDTH / BYTE_WIDTH);
  logic [CACHE_LINE_WIDTH-1:0] lines_n [MEM_DEPTH];
  logic [CACHE_LINE_WIDTH-1:0] lines_q [MEM_DEPTH];
  logic [CACHE_LINE_WIDTH-1:0] lines_tmp [MEM_DEPTH];

  logic [CACHE_LINE_WIDTH-1:0] load_output;
  logic mem_req_w;
  assign load_output = lines_q[req_address[ADDRESS_WIDTH-1:LINE_OFFSET]];
  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic req;
    logic req_store;
  } mem_req, mem_req_delayed;


  // STORE LOGIC
  assign lines_n  = lines_q;
  assign lines_n[req_address[ADDRESS_WIDTH-1:LINE_OFFSET]] = mem_req_delayed.data;

  always_ff @( posedge clk ) begin
    if (mem_req_delayed.req_store & mem_req_delayed.req) begin
      lines_q <= lines_n;
    end
  end
  assign mem_req.data = req_evict_data;
  assign mem_req.addr = req_address;
  assign mem_req.req = req;
  assign mem_req.req_store = req_store;
  

  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 1)
  ) long_way_in (
      .clk(clk),
      .enable(1'b1),
      .reset(mem_req_delayed.req),
      .inp(mem_req),
      .out(mem_req_delayed)
  );


  // READ LOGIC
  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic valid;
  } delayed_fill, fill_out;
  assign delayed_fill.data = load_output;
  assign delayed_fill.addr = req_address;
  assign delayed_fill.valid = req & ~req_store;

  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 1)
  ) long_way_back (
      .clk(clk),
      .enable(1'b1),
      .reset(fill),
      .inp(delayed_fill),
      .out(fill_out)
  );

  assign fill_data = fill_out.data;
  assign fill_address = fill_out.addr;
  assign fill = fill_out.valid;

endmodule




