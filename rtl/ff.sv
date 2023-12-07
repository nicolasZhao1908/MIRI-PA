`include "brisc_pkg.svh"

module ff
  import brisc_pkg::*;
#(
    parameter integer unsigned WIDTH = REG_LEN
) (
    input logic clk,
    input logic enable,
    input logic reset,  // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);
  always_ff @(posedge clk) begin
    if (reset) begin
      out <= 'b0;
    end else if (enable) begin
      out <= inp;
    end
  end

endmodule
