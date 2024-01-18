`include "brisc_pkg.svh"

module core_top
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset
);

  logic req;
  logic req_store;
  logic [ADDRESS_WIDTH-1:0] req_addr;
  logic [CACHE_LINE_WIDTH-1:0] req_data;
  logic [CACHE_LINE_WIDTH-1:0] fill_data;
  logic [ADDRESS_WIDTH-1:0] fill_addr;
  logic fill;

  core brisc_core (
      .clk  (clk),
      .reset(reset),

      .mem_fill(fill),
      .mem_fill_data(fill_data),
      .mem_fill_addr(fill_addr),

      .mem_req  (req),
      .mem_store(req_store),
      .mem_addr (req_addr),
      .mem_data (req_data)
  );

  memory mem (
      .clk(clk),
      .req(req),
      .req_store(req_store),
      .req_addr(req_addr),
      .req_evict_data(req_data),

      .fill_data(fill_data),
      .fill_addr(fill_addr),
      .fill(fill)
  );

endmodule
