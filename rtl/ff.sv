`include "brisc_pkg.svh"

module ff
  import brisc_pkg::*;
#(
    parameter integer unsigned WIDTH = REG_LEN,
    parameter integer unsigned RESET_VALUE = {WIDTH{1'b0}}
) (
    input logic clk,
    input logic enable,
    input logic reset,  // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);
  always_ff @(posedge clk) begin
    if (reset) begin
      out <= RESET_VALUE;
    end else if (enable) begin
      out <= inp;
    end
  end
endmodule
