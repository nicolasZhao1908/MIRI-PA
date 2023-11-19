/*
* Write through cache
*/
`include "brisc_pkg.svh"

module cache
  import brisc_pkg::*;
#(
    parameter int unsigned CACHE_LINE_OFFSET_BITS = $clog2(CACHE_LINE_LEN / BYTE_LEN),  // PC[5:0]
    parameter int unsigned WORLD_OFFSET_BITS = $clog2(CACHE_LINE_LEN / BYTE_LEN),  // PC[5:2]
    parameter int unsigned BYTE_OFFSET_BITS = $clog2(ILEN / BYTE_LEN),  // PC[1:0]
    parameter int unsigned TAG_BITS = ADDRESS_BITS - CACHE_LINE_OFFSET_BITS,
    parameter int unsigned ASSOCIATIVITY = 1,
    parameter int unsigned N_WAY = 2
) (
    input logic clk,
    input logic enable,
    input logic [REG_LEN-1:0] in_data,
    input logic [TAG_BITS-1:0] v_address,
    input logic tlb_hit,
    input logic mem_resp,
    input logic grant,
    input logic [CACHE_LINE_LEN-1:0] fill,  // data from memory

    output logic mem_req,
    output logic hit,
    output logic mem_instr,  // 0 -> store; 1 -> load
    output logic [TAG_BITS-1:0] p_address,
    output logic [REG_LEN-1:0] out_data
);


endmodule


module cache_line(
    input logic clk,
    input logic overwrite,
    input logic in_valid,
    input [TAG_BITS-1:0] logic in_tag,
    input [REG_LEN-1:0] logic in_data,
    output logic out_valid,
    output [TAG_BITS-1:0] logic out_tag,
    output [REG_LEN-1:0] logic out_data
  );

  always_ff @( posedge clk ) begin : writeInChache
    if (overwrite) begin
      out_valid <= in_valid;
      out_tag <= in_tag;
      out_data <= in_data;
    end
  end


endmodule

