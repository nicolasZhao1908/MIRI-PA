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
  logic [ADDRESS_WIDTH-BYTE_OFFSET_WIDTH-1:0] word_addr_delayed;

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
      mem_req_aux[MEM_REQ_DELAY], mem_req_delayed;

  struct packed {
    logic [CACHE_LINE_WIDTH-1:0] data;
    logic [ADDRESS_WIDTH-1:0] addr;
    logic valid;
  }
      fill_aux[MEM_RESP_DELAY], fill_delayed;

  always_comb begin
    // Write logic

    datas_n = datas_q;

    mem_req_aux[0].data = req_evict_data;
    mem_req_aux[0].addr = req_addr;
    mem_req_aux[0].req = req;
    mem_req_aux[0].req_store = req_store;

    word_addr_delayed = mem_req_delayed.addr[ADDRESS_WIDTH-1:BYTE_OFFSET_WIDTH];

    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      // TODO
      datas_n[word_addr_delayed+i] |= mem_req_delayed.data[i*WORD_WIDTH+:WORD_WIDTH];
    end

    // Read logic
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      read_data[i*WORD_WIDTH+:WORD_WIDTH] = datas_q[word_addr_delayed+i];
    end
    fill_aux[0].data = read_data;
    fill_aux[0].addr = mem_req_delayed.addr;
    fill_aux[0].valid = mem_req_delayed.req & ~mem_req_delayed.req_store;


    fill_data = fill_delayed.data;
    fill_addr = fill_delayed.addr;
    fill = fill_delayed.valid;
  end


  always_ff @(posedge clk) begin
    if (mem_req_delayed.req & mem_req_delayed.req_store) begin
      datas_q <= datas_n;
    end
    if (fill_delayed.valid) begin
      for (int unsigned i = 0; i < MEM_REQ_DELAY; ++i) begin
        fill_aux[i] <= '{default: 0};
      end
    end

    for (int unsigned i = 0; i < MEM_REQ_DELAY - 1; ++i) begin
      mem_req_aux[i+1] <= mem_req_aux[i];
    end
    mem_req_delayed <= mem_req_aux[MEM_REQ_DELAY-1];

    for (int unsigned i = 0; i < MEM_RESP_DELAY - 1; ++i) begin
      fill_aux[i+1] <= fill_aux[i];
    end
    fill_delayed <= fill_aux[MEM_RESP_DELAY-1];
  end


  // nff #(
  //     .N(MEM_REQ_DELAY),
  //     .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 2)
  // ) long_way_in (
  //     .clk(clk),
  //     .enable(1'b1),
  //     // Pipelined mem operations
  //     .reset(1'b0),
  //     .inp(mem_req_aux),
  //     .out(mem_req_delayed)
  // );
  // nff #(
  //     .N(MEM_RESP_DELAY),
  //     .WIDTH(CACHE_LINE_WIDTH + ADDRESS_WIDTH + 1)
  // ) long_way_back (
  //     .clk(clk),
  //     .enable(1'b1),  //mem_req_delayed.req & ~mem_req_delayed.req_store
  //     .reset(1'b0),
  //     .inp(fill_aux),
  //     .out(fill_delayed)
  // );



endmodule




