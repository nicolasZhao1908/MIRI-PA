`include "brisc_pkg.svh"

module dcache  import brisc_pkg::*; #(
    parameter integer unsigned SET_BIT_WIDTH = 2,
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned CACHE_LINE_WIDTH = 128
) (
    input logic clk,
    input logic enable,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [XLEN-1:0] data_in,
    input logic word,  //Defines whether a word or a byte should be loaded or stored

    //Arbiter input
    input logic arbiter_grant,

    //Mem inputs
    input logic [CACHE_LINE_WIDTH-1:0] fill_data_from_mem,
    input logic fill_data_from_mem_valid,

    //Mem outputs
    output logic req_store_to_mem,
    output logic req_word_to_mem,
    output logic [ADDRESS_WIDTH-1:0] req_addr_to_mem,
    output logic [XLEN-1:0] req_store_data_to_mem,

    //Arbiter outputs
    output logic req_to_arbiter,

    output logic hit,
    output logic [XLEN-1:0] data_out
);

  localparam integer unsigned CACHE_LINE_BIT_OFFSET = $clog2(CACHE_LINE_WIDTH / XLEN * 4);

  logic [ADDRESS_WIDTH - CACHE_LINE_BIT_OFFSET - 1:0] truncated_address_for_cache;
  logic [CACHE_LINE_BIT_OFFSET-1:0] part_in_cacheline;

  assign truncated_address_for_cache = addr[ADDRESS_WIDTH-1:CACHE_LINE_BIT_OFFSET];
  assign part_in_cacheline = addr[CACHE_LINE_BIT_OFFSET-1:2];

  logic write_in_cache_unit;

  logic cache_unit_hit;
  logic [CACHE_LINE_WIDTH-1:0] data_out_cache_unit;


  cache #(
      .SET_BIT_WIDTH(SET_BIT_WIDTH),
      .INPUT_WIDTH(ADDRESS_WIDTH - CACHE_LINE_BIT_OFFSET),
      .DATA_WIDTH(CACHE_LINE_WIDTH)
  ) cache_unit (
      .clk(clk),
      .read_write(write_in_cache_unit),
      .inp(truncated_address_for_cache),
      .data_in(fill_data_from_mem),
      .valid_in(~store),
      .hit(cache_unit_hit),
      .data_out(data_out_cache_unit)
  );

  assign write_in_cache_unit = store | (arbiter_grant & fill_data_from_mem_valid & ~cache_unit_hit);

  assign req_to_arbiter = (~cache_unit_hit | store) & enable;

  assign req_word_to_mem = word;
  assign req_store_to_mem = store;
  assign req_addr_to_mem = addr;
  assign req_store_data_to_mem = data_in;

  //logic delay_arbiter_grant_store;
  //...

  assign hit = (cache_unit_hit & ~store) | (store & arbiter_grant);

  logic [XLEN-1:0] word_out;
  assign word_out = data_out_cache_unit[part_in_cacheline*XLEN+:XLEN];
  logic [1:0] byte_in_word;
  assign byte_in_word = addr[1:0];

  assign data_out = word ? word_out : {{8 * 3{1'b0}}, word_out[byte_in_word*8+:8]};
endmodule

module two_caches_arbiter_testonly #(
    parameter integer unsigned SET_BIT_WIDTH = 2,
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = 32,
    parameter integer unsigned MEM_DATA_WIDTH = 8,
    parameter integer unsigned CACHE_LINE_WIDTH = 128
) (
    input logic clk,
    input logic enable_1,
    input logic store_1,
    input logic word_1,
    input logic [ADDRESS_WIDTH-1:0] addr_1,
    input logic [DATA_WIDTH-1:0] data_in_1,

    input logic enable_2,
    input logic store_2,
    input logic word_2,
    input logic [ADDRESS_WIDTH-1:0] addr_2,
    input logic [DATA_WIDTH-1:0] data_in_2,

    output logic hit_1,
    output logic [DATA_WIDTH-1:0] data_out_1,

    output logic hit_2,
    output logic [DATA_WIDTH-1:0] data_out_2

    // ,output logic [3:0] rg_out
    // ,output logic [1:0] mem_resp
    // ,output logic [DATA_WIDTH-1:0] arb2mem
    // ,output logic [CACHE_LINE_WIDTH-1:0] mem2arb
    // ,output logic [ADDRESS_WIDTH-1:0] arb2memAddr
    // ,output logic arb2memStr
    // ,output logic [0:0] enables_out [128]
    // ,output logic strAndReq
    // ,output logic [6:0] controlAddr
    // ,output logic [128:0] mem_oi
    // ,output logic [32-1:0] data_out_out [128]
    // ,output logic [32-1:0] evict_data_out
);

  logic [CACHE_LINE_WIDTH-1:0] fill_from_mem;
  logic valid_from_mem;


  logic req_store_to_mem_1;
  logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_1;
  logic [DATA_WIDTH-1:0] req_store_data_to_mem_1;
  logic req_word_to_mem_1;

  logic req_store_to_mem_2;
  logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_2;
  logic [DATA_WIDTH-1:0] req_store_data_to_mem_2;
  logic req_word_to_mem_2;

  logic req_to_mem_arb;
  logic req_store_to_mem_arb;
  logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_arb;
  logic [DATA_WIDTH-1:0] req_store_data_to_mem_arb;
  logic req_store_word_to_mem_arb;

  logic req_to_arbiter_1;
  logic req_to_arbiter_2;
  logic grant_from_arbiter_1;
  logic grant_from_arbiter_2;


  cache #(
      .SET_BIT_WIDTH(SET_BIT_WIDTH),
      .ADDRESS_WIDTH(XLEN),
      .DATA_WIDTH(DATA_WIDTH),
      .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH)
  ) dcache_unit_1 (
      .clk(clk),
      .enable(enable_1),
      .store(store_1),
      .addr(addr_1),
      .word(word_1),
      .data_in(data_in_1),
      .arbiter_grant(grant_from_arbiter_1),
      .fill_data_from_mem(fill_from_mem),
      .fill_data_from_mem_valid(valid_from_mem),
      .req_store_to_mem(req_store_to_mem_1),
      .req_addr_to_mem(req_addr_to_mem_1),
      .req_store_data_to_mem(req_store_data_to_mem_1),
      .req_to_arbiter(req_to_arbiter_1),
      .req_word_to_mem(req_word_to_mem_1),
      .hit(hit_1),
      .data_out(data_out_1)
  );

  cache #(
      .SET_BIT_WIDTH(SET_BIT_WIDTH),
      .ADDRESS_WIDTH(XLEN),
      .DATA_WIDTH(DATA_WIDTH),
      .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH)
  ) dcache_unit_2 (
      .clk(clk),
      .enable(enable_2),
      .store(store_2),
      .addr(addr_2),
      .word(word_2),
      .data_in(data_in_2),
      .arbiter_grant(grant_from_arbiter_2),
      .fill_data_from_mem(fill_from_mem),
      .fill_data_from_mem_valid(valid_from_mem),
      .req_store_to_mem(req_store_to_mem_2),
      .req_addr_to_mem(req_addr_to_mem_2),
      .req_store_data_to_mem(req_store_data_to_mem_2),
      .req_to_arbiter(req_to_arbiter_2),
      .req_word_to_mem(req_word_to_mem_2),
      .hit(hit_2),
      .data_out(data_out_2)
  );

  arbiter arb (
      .clk(clk),
      .req_1(req_to_arbiter_1),
      .store_to_mem_1(req_store_to_mem_1),
      .addr_to_mem_1(req_addr_to_mem_1),
      .data_to_mem_1(req_store_data_to_mem_1),
      .store_word_1(req_word_to_mem_1),
      .req_2(req_to_arbiter_2),
      .store_to_mem_2(req_store_to_mem_2),
      .addr_to_mem_2(req_addr_to_mem_2),
      .data_to_mem_2(req_store_data_to_mem_2),
      .store_word_2(req_word_to_mem_2),
      .grant_1(grant_from_arbiter_1),
      .grant_2(grant_from_arbiter_2),
      .request_to_mem(req_to_mem_arb),
      .store_to_mem(req_store_to_mem_arb),
      .addr_to_mem(req_addr_to_mem_arb),
      .data_to_mem(req_store_data_to_mem_arb),
      .store_word_to_mem(req_store_word_to_mem_arb)
  );

  memory #(
      .FILL_DATA_WIDTH(CACHE_LINE_WIDTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .STORE_DATA_WIDTH(MEM_DATA_WIDTH)
  ) mem (
      .clk(clk),
      .req(req_to_mem_arb),
      .store(req_store_to_mem_arb),
      .storeWord(req_store_word_to_mem_arb),
      .address(req_addr_to_mem_arb),
      .evict_data(req_store_data_to_mem_arb),
      .fill_data(fill_from_mem),
      .response_valid(valid_from_mem)
  );

  //ADDITIONAL DEBUG STATEMENTS FOR MEM: , enables_out, strAndReq, controlAddr, mem_oi, cabels, data_out_out, evict_data_out
  //DEBUG

  // assign rg_out = {req_to_arbiter_1, grant_from_arbiter_1, req_to_arbiter_2, grant_from_arbiter_2};
  // assign mem_resp = {req_to_mem_arb, valid_from_mem};
  // assign arb2mem = req_store_data_to_mem_arb;
  // assign mem2arb = fill_from_mem;
  // assign arb2memAddr = req_addr_to_mem_arb;
  // assign arb2memStr = req_store_to_mem_arb; 
endmodule

module dcache_mem_testonly #(
    parameter integer unsigned SET_BIT_WIDTH = 2,
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = 32,
    parameter integer unsigned MEM_DATA_WIDTH = 8,
    parameter integer unsigned CACHE_LINE_WIDTH = 128
) (
    input logic clk,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic word,

    output logic hit,
    output logic [DATA_WIDTH-1:0] data_out

    // , output logic [CACHE_LINE_WIDTH-1: 0] fillD
    // , output logic [DATA_WIDTH - 1:0] sendD
    // , output logic [0:0] enables [512]
    // , output logic [8-1:0] data_out_out [128*4]
    // , output logic [CACHE_LINE_WIDTH-1:0] data_out_cache_unit_o
    // , output logic [DATA_WIDTH-1:0] word_out_out
);

  logic [CACHE_LINE_WIDTH-1:0] fill_from_mem;
  logic valid_from_mem;

  logic req_to_mem;
  logic req_store_to_mem;
  logic [ADDRESS_WIDTH-1:0] req_addr_to_mem;
  logic [DATA_WIDTH-1:0] req_store_data_to_mem;
  logic word_to_mem;

  logic arbiter_grant;

  cache #(
      .SET_BIT_WIDTH(SET_BIT_WIDTH),
      .ADDRESS_WIDTH(XLEN),
      .DATA_WIDTH(DATA_WIDTH),
      .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH)
  ) dcache_unit (
      .clk(clk),
      .enable(1'b1),
      .store(store),
      .addr(addr),
      .data_in(data_in),
      .word(word),
      .arbiter_grant(arbiter_grant),
      .fill_data_from_mem(fill_from_mem),
      .fill_data_from_mem_valid(valid_from_mem),
      .req_store_to_mem(req_store_to_mem),
      .req_addr_to_mem(req_addr_to_mem),
      .req_store_data_to_mem(req_store_data_to_mem),
      .req_to_arbiter(arbiter_grant),
      .hit(hit),
      .req_word_to_mem(word_to_mem),
      .data_out(data_out)

      //   , .word_out_out(word_out_out)
      //   , .data_out_cache_unit_o(data_out_cache_unit_o)
  );

  assign req_to_mem = arbiter_grant;
  memory #(
      .FILL_DATA_WIDTH(CACHE_LINE_WIDTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .STORE_DATA_WIDTH(MEM_DATA_WIDTH)
  ) mem (
      .clk(clk),
      .req(req_to_mem),
      .store(req_store_to_mem),
      .storeWord(word_to_mem),
      .address(req_addr_to_mem),
      .evict_data(req_store_data_to_mem),
      .fill_data(fill_from_mem),
      .response_valid(valid_from_mem)
  );

  //   assign fillD = fill_from_mem;
  //   assign sendD = req_store_data_to_mem;

endmodule

