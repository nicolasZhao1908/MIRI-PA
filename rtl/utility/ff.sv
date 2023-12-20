`ifndef FF_SV
`define FF_SV
`include "brisc_pkg.svh"

`timescale 1ns / 1ps

module ff
  import brisc_pkg::*;
#(
    parameter integer unsigned WIDTH = XLEN,
    parameter [WIDTH-1:0] RESET_VALUE = 0
) (
    input logic clk,
    input logic enable,
    input logic reset,  // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);
  initial begin
    assign out = RESET_VALUE;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
       out <= RESET_VALUE;
    end
    else if (enable) begin
        out <= inp;
    end
    else begin
       out <= out;
    end
  end
endmodule

module nff #(
    parameter integer unsigned N = 3,
    parameter integer unsigned WIDTH = 1,
    parameter integer unsigned RESET_VALUE = 0
) (
    input logic clk,
    input logic enable,
    input logic reset_1,
    input logic reset_1_to_N,  // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);

  logic [WIDTH - 1:0] in_cable[N + 1];

  assign in_cable[0] = inp;

  genvar i;
  generate
    for (i = 0; i < N; i++) begin : g_nff
      ff #(
          .WIDTH(WIDTH),
          .RESET_VALUE(RESET_VALUE)
      ) flip_flop (
          .clk(clk),
          .enable(enable),
          .reset(i == 0 ? reset_1 : reset_1_to_N),
          .inp(in_cable[i]),
          .out(in_cable[i+1])
      );
    end
  endgenerate
  assign out = in_cable[N];
endmodule

`endif
