`include "brisc_pkg.svh"

module nff #(
    parameter integer unsigned N = 3,
    parameter integer unsigned WIDTH = 1,
    parameter integer unsigned RESET_VALUE = 0
) (
    input logic clk,
    input logic enable,
    input logic reset,
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
          .reset(reset),
          .inp(in_cable[i]),
          .out(in_cable[i+1])
      );
    end
  endgenerate
  assign out = in_cable[N];
endmodule
