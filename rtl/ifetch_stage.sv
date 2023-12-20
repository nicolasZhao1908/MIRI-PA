`include "brisc_pkg.svh"
`include "cache/dcache.sv"
`include "utility/ff.sv"
module ifetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_fetch,
    input logic b_taken,
    input logic [ADDRESS_BITS-1:0] b_target,

    //For the cache:
    //Arbiter input
    input logic arbiter_grant,

    //Mem inputs
    input logic [CACHE_LINE_LEN-1:0] fill_data_from_mem,
    input logic fill_data_from_mem_valid,

    //Mem outputs
    output logic [ADDRESS_BITS-1:0] req_addr_to_mem,

    //Arbiter outputs
    output logic req_to_arbiter,

    //Normal outputs:
    output logic [ILEN-1:0] instr,
    output logic stall
);
  logic [XLEN-1:0] pc_next;
  logic [XLEN-1:0] pc_curr;

  logic pc_update;
  logic cache_hit;

  assign pc_update = !stall_fetch;
  assign pc_next   = b_taken ? b_target : pc_curr + 4;

  ff #(
      .WIDTH(32),
      .RESET_VALUE(PC_BOOT)
  ) pc (
      .clk(clk),
      .enable(pc_update),
      .reset(reset),
      .inp(pc_next),
      .out(pc_curr)
  );



  // cache icache (
  //     .clk(clk),
  //     .read_write(1'b0),
  //     .inp(pc_curr),
  //     .data_in('0),
  //     .valid_in(1'b1),
  //     .hit(cache_hit),
  //     .data_out(instr)
  // );

  dcache #( // Use DCache as ICache lol
    .SET_BIT_WIDTH($clog2(CACHE_LINES)),
    .ADDRESS_WIDTH(ADDRESS_BITS),
    .DATA_WIDTH(XLEN),
    .CACHE_LINE_WIDTH(CACHE_LINE_LEN)
  ) cache (
    .clk(clk),
    .enable(1'b1),
    .store(1'b0),
    .addr(pc_curr),
    .data_in({ADDRESS_BITS{1'b0}}), //Nothing to be stored in ICache
    .word(1'b1), //Defines whether a word or a byte should be loaded or stored

    //Arbiter input
    .arbiter_grant(arbiter_grant),

    //Mem inputs
    .fill_data_from_mem(fill_data_from_mem),
    .fill_data_from_mem_valid(fill_data_from_mem_valid),

    //Mem outputs
    .req_store_to_mem(),
    .req_word_to_mem(),
    .req_addr_to_mem(req_addr_to_mem),
    .req_store_data_to_mem(),

    //Arbiter outputs
    .req_to_arbiter(req_to_arbiter),

    //Cache outputs
    .hit(cache_hit),
    .data_out(instr)
  );

  assign stall = !cache_hit;
endmodule
