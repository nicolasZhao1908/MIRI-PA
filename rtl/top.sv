`include "brisc_pkg.svh"

module top
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset
);
  mem_req_t  mem_req;
  mem_resp_t mem_resp;


  core brisc_core (
      .clk(clk),
      .reset(reset),
      .mem_req(mem_req),
      .mem_resp(mem_resp)
  );

  memory mem (
      .clk(clk),
      .req (mem_req),
      .resp(mem_resp)
  );

endmodule
