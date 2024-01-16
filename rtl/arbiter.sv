`include "brisc_pkg.svh"

module arbiter
  import brisc_pkg::*;
#(
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = 32
) (
    input logic clk,

    input logic mem_req_1,
    input logic mem_write_1,
    input data_size_e data_size_1,
    input logic [ADDRESS_WIDTH-1:0] mem_addr_1,
    input logic [DATA_WIDTH-1:0] mem_data_1,

    input logic mem_req_2,
    input logic mem_write_2,
    input data_size_e data_size_2,
    input logic [ADDRESS_WIDTH-1:0] mem_addr_2,
    input logic [DATA_WIDTH-1:0] mem_data_2,

    output logic grant_1,
    output logic grant_2,

    output logic mem_req,
    output logic mem_write,
    output data_size_e data_size,
    output logic [ADDRESS_WIDTH-1:0] mem_addr,
    output logic [DATA_WIDTH-1:0] mem_data
);

  logic gr2;
  logic ff_out;

  assign gr2 = mem_req_2 & (ff_out | ~mem_req_1);

  ff #(
      .WIDTH(1)
  ) req2_running (
      .clk(clk),
      .enable(1'b1),
      .reset(1'b0),
      .inp(gr2),
      .out(ff_out)
  );

  /* logic grant_1_start_allowed; //This code should work, and would make the arb faster, but for some verilog reason it creates undefined behavior...
    assign grant_1_start_allowed = ~(ff_out & req_2) & req_1;
    logic grant_1_stableizer_ff_out;
    ff clock_stabelizer_ff1 (clk, 1'b1, 1'b0, grant_1_start_allowed, grant_1_stableizer_ff_out);

    logic grant_2_start_allowed;
    assign grant_2_start_allowed = gr2;
    logic grant_2_stableizer_ff_out;
    ff clock_stabelizer_ff2 (clk, 1'b1, 1'b0, grant_2_start_allowed, grant_2_stableizer_ff_out);

    assign grant_1 = (grant_1_stableizer_ff_out & req_1) | (grant_1_start_allowed & ~clk);
    assign grant_2 = (grant_2_stableizer_ff_out & req_2) | (grant_2_start_allowed & ~clk);
    */

  logic grant_1_stableizer_ff_out;
  ff #(
      .WIDTH(1)
  ) stabelizer_ff1 (
      .clk(~clk),
      .enable(1'b1),
      .reset(1'b0),
      .inp(~(ff_out & mem_req_2) & mem_req_1),
      .out(grant_1_stableizer_ff_out)
  );
  assign grant_1 = grant_1_stableizer_ff_out & (~(ff_out & mem_req_2) & mem_req_1);

  logic grant_2_stableizer_ff_out;
  ff #(
      .WIDTH(1)
  ) stabelizer_ff2 (
      .clk(~clk),
      .enable(1'b1),
      .reset(1'b0),
      .inp(gr2),
      .out(grant_2_stableizer_ff_out)
  );
  assign grant_2 = grant_2_stableizer_ff_out & gr2;
  assign mem_req = grant_1 | grant_2;

  // prioritize grant from instruction cache
  assign mem_write = grant_1 ? mem_write_1 : mem_write_2;
  assign mem_addr = grant_1 ? mem_addr_1 : mem_addr_2;
  assign mem_data = grant_1 ? mem_data_1 : mem_data_2;
  assign data_size = grant_1 ? data_size_1 : data_size_2;
endmodule
