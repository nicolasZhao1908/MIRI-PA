`include "brisc_pkg.svh"

module memory
  import brisc_pkg::*;
#(
    parameter int unsigned MEM_DEPTH = brisc_pkg::MEM_DEPTH

) (
    input logic clk,
    input mem_req_t req,
    output mem_resp_t resp
);
  localparam int unsigned WORDS_IN_LINE = CACHE_LINE_LEN / WORD_LEN;
  localparam int unsigned BYTE_OFFSET_LEN = $clog2(WORD_LEN / BYTE_LEN);


  logic [XLEN-1:0] datas_n[MEM_DEPTH];
  logic [XLEN-1:0] datas_q[MEM_DEPTH];

  logic [CACHE_LINE_LEN-1:0] read_data;
  logic [ADDR_LEN-BYTE_OFFSET_LEN-1:0] word_addr_delayed;

  initial begin
    // read both instructions and data
    $readmemh("programs/mem.hex", datas_q);
  end

  struct packed {
    logic [CACHE_LINE_LEN-1:0] data;
    logic [ADDR_LEN-1:0] addr;
    logic req;
    logic req_store;
  }
      mem_req_aux[MEM_REQ_DELAY], mem_req_delayed;

  struct packed {
    logic [CACHE_LINE_LEN-1:0] data;
    logic [ADDR_LEN-1:0] addr;
    logic ready;
  }
      fill_aux[MEM_RESP_DELAY], fill_delayed;

  always_comb begin
    // Write logic

    datas_n = datas_q;

    mem_req_aux[0].data = req.data;
    mem_req_aux[0].addr = req.addr;
    mem_req_aux[0].req = req.valid;
    mem_req_aux[0].req_store = req.rw;

    word_addr_delayed = mem_req_delayed.addr[ADDR_LEN-1:BYTE_OFFSET_LEN];

    /* verilator lint_off WIDTH  */
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      datas_n[word_addr_delayed+i] = mem_req_delayed.data[i*WORD_LEN+:WORD_LEN];
    end

    // Read logic
    for (int unsigned i = 0; i < WORDS_IN_LINE; ++i) begin
      read_data[i*WORD_LEN+:WORD_LEN] = datas_q[word_addr_delayed+i];
    end
    fill_aux[0].data = read_data;
    fill_aux[0].addr = mem_req_delayed.addr;
    fill_aux[0].ready = mem_req_delayed.req & ~mem_req_delayed.req_store;


    resp.data = fill_delayed.data;
    resp.addr = fill_delayed.addr;
    resp.ready = fill_delayed.ready;
  end


  always_ff @(posedge clk) begin
    if (mem_req_delayed.req & mem_req_delayed.req_store) begin
      datas_q <= datas_n;
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

endmodule




