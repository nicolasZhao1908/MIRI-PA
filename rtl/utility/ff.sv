`ifndef FF_SV
`define FF_SV

`timescale 1ns / 1ps

module ff #(
    // flipflop stores 1 bit of data
    parameter integer WIDTH = 1,
    parameter bit RESET_VALUE = 1'b0
) (
    input logic clk,
    input logic enable,
    input logic reset,  // active high synchronous reset
    input logic [WIDTH - 1:0] in,
    output logic [WIDTH - 1:0] out
);
  always @(posedge clk) begin
    if (reset) out <= RESET_VALUE;
    else if (enable) out <= in;
    else out <= out;
  end

endmodule

module nff #(
    parameter integer N = 3,
    parameter integer WIDTH = 1,
    parameter integer RESET_VALUE = 0
) (
    input logic clk,
    input logic enable,
    input logic reset_1,
    input logic reset_1_to_N,  // active high synchronous reset
    input logic [WIDTH - 1:0] in,
    output logic [WIDTH - 1:0] out
);

  logic [WIDTH - 1:0] in_cable[N + 1];

  assign in_cable[0] = in;

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
          .in(in_cable[i]),
          .out(in_cable[i+1])
      );
    end
  endgenerate
  assign out = in_cable[N];
endmodule

`endif
