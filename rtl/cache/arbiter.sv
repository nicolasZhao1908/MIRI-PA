`include "utility/ff.sv"

module arbiter #(
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = 32
) (
    input logic clk,
    input logic req_1,
    input logic store_to_mem_1,
    input logic store_word_1,
    input logic [ADDRESS_WIDTH-1:0] addr_to_mem_1,
    input logic [DATA_WIDTH-1:0] data_to_mem_1,

    input logic req_2,
    input logic store_to_mem_2,
    input logic store_word_2,
    input logic [ADDRESS_WIDTH-1:0] addr_to_mem_2,
    input logic [DATA_WIDTH-1:0] data_to_mem_2,


    output logic grant_1,
    output logic grant_2,

    output logic request_to_mem,
    output logic store_to_mem,
    output logic store_word_to_mem,
    output logic [ADDRESS_WIDTH-1:0] addr_to_mem,
    output logic [DATA_WIDTH-1:0] data_to_mem
);

  logic gr2;
  logic ff_out;

  assign gr2 = req_2 & (ff_out | ~req_1);

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
      .inp(~(ff_out & req_2) & req_1),
      .out(grant_1_stableizer_ff_out)
  );
  assign grant_1 = grant_1_stableizer_ff_out & (~(ff_out & req_2) & req_1);

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

  assign request_to_mem = grant_1 | grant_2;
  assign store_to_mem = grant_1 ? store_to_mem_1 : store_to_mem_2;
  assign addr_to_mem = grant_1 ? addr_to_mem_1 : addr_to_mem_2;
  assign data_to_mem = grant_1 ? data_to_mem_1 : data_to_mem_2;
  assign store_word_to_mem = grant_1 ? store_word_1 : store_word_2;
endmodule
