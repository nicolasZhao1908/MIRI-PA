`include "const.svh"
/*
* Write through cache
*/

module cache #(
    parameter CACHE_LINE_LEN = `CACHE_LINE_LEN,
    parameter DATA_LEN = `REG_LEN,
    parameter CACHE_LINE_OFFSET_BITS = $clog2(`CACHE_LINE_LEN / `BYTE_LEN),  // PC[5:0]
    parameter WORLD_OFFSET_BITS = $clog2(`CACHE_LINE_LEN / `BYTE_LEN),  // PC[5:2]
    parameter BYTE_OFFSET_BITS = $clog2(`ILEN / `BYTE_LEN),  // PC[1:0]
    parameter TAG_BITS = `ADDRESS_BITS - CACHE_LINE_OFFSET_BITS,
    parameter ASSOCIATIVITY = 1
) (
    input logic clk,
    input logic enable,
    input logic [DATA_LEN-1:0] in_data,
    input logic [TAG_BITS-1:0] v_address,
    input logic tlb_hit,
    input logic mem_resp,
    input logic grant,
    input logic [CACHE_LINE_LEN-1:0] fill,  // data from memory

    output logic mem_req,
    output logic hit,
    output logic mem_instr,  // 0 -> store; 1 -> load
    output logic [TAG_BITS-1:0] p_address,
    output logic [DATA_LEN-1:0] out_data
);

endmodule


