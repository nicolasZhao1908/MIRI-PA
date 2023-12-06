`include "brisc_pkg.svh"

module cache_line
  import brisc_pkg::*;
#(
    parameter int unsigned CACHE_LINE_OFFSET_BITS = $clog2(CACHE_LINE_LEN / BYTE_LEN),  // PC[5:0]
    parameter int unsigned TAG_BITS = ADDRESS_BITS - CACHE_LINE_OFFSET_BITS
)(
    input logic clk,
    input logic overwrite,
    input logic in_valid,
    input [TAG_BITS-1:0] in_tag,
    input [REG_LEN-1:0] in_data,
    output out_valid,
    output [TAG_BITS-1:0] out_tag,
    output [REG_LEN-1:0] out_data
);

  always_ff @(posedge clk) begin : writeInChache
    if (overwrite) begin
      out_valid <= in_valid;
      out_tag   <= in_tag;
      out_data  <= in_data;
    end
  end
endmodule
