`include "brisc_pkg.svh"

module ff
  import brisc_pkg::*;
#(
    parameter int unsigned WIDTH = XLEN,
    parameter int unsigned RESET_VALUE = '0
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
